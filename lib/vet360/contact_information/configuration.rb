# frozen_string_literal: true

require 'vet360/configuration'

module Vet360
  module ContactInformation
    class Configuration < Vet360::Configuration
      self.read_timeout = Settings.vet360.contact_information.timeout || 30

      def base_path
        "#{Settings.vet360.url}/contact-information-hub/cuf/contact-information/v1"
      end

      def service_name
        'Vet360/ContactInformation'
      end

      def mock_enabled?
        Settings.vet360.contact_information.mock || false
      end
    end
  end
end
