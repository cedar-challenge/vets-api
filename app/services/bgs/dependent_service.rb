# frozen_string_literal: true

module BGS
  class DependentService < BaseService
    def get_dependents
      @service.claimant.find_dependents_by_participant_id(@user.participant_id, @user.ssn)
    end

    def submit_686c_form(claim)
      bgs_person = @service.people.find_person_by_ptcpnt_id(@user.participant_id)

      # rubocop:disable Rails/DynamicFindBy
      bgs_person = @service.people.find_by_ssn(@user.ssn) if bgs_person.nil?
      # rubocop:enable Rails/DynamicFindBy

      vet_info = VetInfo.new(@user, bgs_person)

      BGS::SubmitForm686cJob.perform_async(@user.uuid, claim.id, vet_info.to_686c_form_hash) if claim.submittable_686?
      BGS::SubmitForm674Job.perform_async(@user.uuid, claim.id, vet_info.to_686c_form_hash) if claim.submittable_674?
      VBMS::SubmitDependentsPdfJob.perform_async(
        saved_claim_id: claim.id,
        va_file_number_with_payload: vet_info.to_686c_form_hash,
        submittable_686: claim.submittable_686?,
        submittable_674: claim.submittable_674?
      )
    rescue => e
      report_error(e)
    end
  end
end
