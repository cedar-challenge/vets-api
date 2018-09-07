# frozen_string_literal: true

module EVSS
  module DisabilityCompensationForm
    class SubmitForm526
      include Sidekiq::Worker
      include SentryLogging

      # Sidekiq has built in exponential back-off functionality for retrys
      # A max retry attempt of 13 will result in a run time of ~25 hours
      RETRY = 13

      sidekiq_options retry: RETRY

      # This callback cannot be tested due to the limitations of `Sidekiq::Testing.fake!`
      sidekiq_retries_exhausted do |msg, _ex|
        transaction_class.update_transaction(jid, :exhausted)
        log_message_to_sentry(
          "Failed all retries on Form526 submit, last error: #{msg['error_message']}",
          :error
        )
      end

      # Performs an asynchronous job for submitting a form526 to an upstream
      # submission service (currently EVSS)
      #
      # @param user_uuid [String] The user's uuid thats associated with the form
      # @param claim_id [String] The claim id for the claim that will be associated with the async transaction
      # @param form_content [Hash] The form content that is to be submitted
      # @param uploads [Hash] The users ancillary uploads that will be submitted separately
      #
      def perform(user_uuid, claim_id, form_content, uploads)
        user = User.find(user_uuid)

        if transaction_class.find_transaction(jid).blank?
          saved_claim(claim_id).async_transaction = transaction_class.start(user, jid)
        end
        response = service(user).submit_form(form_content)
        transaction_class.update_transaction(jid, :received, response.attributes)
        submission_rate_limiter.increment

        Rails.logger.info('Form526 Submission',
                          'user_uuid' => user.uuid,
                          'job_id' => jid,
                          'job_status' => 'received')

        EVSS::DisabilityCompensationForm::SubmitForm526Cleanup.perform_async(user_uuid)
        EVSS::DisabilityCompensationForm::SubmitUploads.start(user, response.claim_id, uploads) if uploads.present?
      rescue EVSS::DisabilityCompensationForm::ServiceException => e
        handle_service_exception(e)
      rescue Common::Exceptions::GatewayTimeout => e
        handle_gateway_timeout_exception(e)
      rescue StandardError => e
        # Treat unexpected errors as hard failures
        # This includes BackeEndService Errors (including 403's)
        handle_standard_error(e)
      end

      private

      def service(user)
        EVSS::DisabilityCompensationForm::Service.new(user)
      end

      def saved_claim(claim_id)
        SavedClaim::DisabilityCompensation.find(claim_id)
      end

      def transaction_class
        AsyncTransaction::EVSS::VA526ezSubmitTransaction
      end

      def handle_service_exception(error)
        if error.status_code.between?(500, 600)
          transaction_class.update_transaction(jid, :retrying, error.messages)
          raise error
        end
        transaction_class.update_transaction(jid, :non_retryable_error, error.messages)
        extra_content = { status: :non_retryable_error, jid: jid }
        log_exception_to_sentry(error, extra_content)
      end

      def handle_gateway_timeout_exception(error)
        transaction_class.update_transaction(jid, :retrying, error.message)
        raise error
      end

      def handle_standard_error(error)
        transaction_class.update_transaction(jid, :non_retryable_error, error.to_s)
        extra_content = { status: :non_retryable_error, jid: jid }
        log_exception_to_sentry(error, extra_content)
      end

      def submission_rate_limiter
        Common::EventRateLimiter.new(REDIS_CONFIG['evss_526_submit_form_rate_limit'])
      end
    end
  end
end
