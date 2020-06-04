# frozen_string_literal: true

require 'common/exceptions/external/unprocessable_entity'
require_relative 'service'
require_relative 'configuration'

module MasterVeteranIndex
  class OrchSearchService < MasterVeteranIndex::Service
    configuration MasterVeteranIndex::Configuration

    private

    def measure_info(user_identity)
      Rails.logger.measure_info(
        'Performed MVI Orchestrated Search Query', payload: logging_context(user_identity)
      ) { yield }
    end

    def create_profile_message(user)
      unless user.valid? && user.edipi.present?
        raise Common::Exceptions::External::UnprocessableEntity.new(
          detail: 'User is invalid or missing edipi',
          source: 'OrchSearchService'
        )
      end

      message_user_attributes(user)
    end

    def message_user_attributes(user)
      given_names = [user.first_name]
      given_names.push user.middle_name unless user.middle_name.nil?
      profile = {
        given_names: given_names,
        last_name: user.last_name,
        birth_date: user.birth_date,
        ssn: user.ssn,
        gender: user.gender
      }
      MasterVeteranIndex::Messages::FindProfileMessage.new(
        profile,
        true,
        user.edipi
      ).to_xml
    end
  end
end
