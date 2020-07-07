# frozen_string_literal: true

module MPI
  class AttrService < Service
    configuration MPI::AttrConfiguration

    private

    def create_profile_message(user_attributes)
      message_user_attributes(user_attributes)
    end

    def measure_info(_user_attributes)
      Rails.logger.measure_info('Performed MPI Query') { yield }
    end
  end
end
