# frozen_string_literal: true

require 'common/models/base'

module EVSS
  module DisabilityCompensationForm
    # Model for findRatingInfoPID service.
    # The findRatingInfoPID service returns information about all the veteran's rated disabilities.
    #
    # @!attribute disability_decision_type_name
    #   @return [String] The disability decision type (ex. Service Connected)
    # @!attribute service_connected_combined_degree
    #   @return [Integer] Service connected combined degree rating (ex. 90)
    # @!attribute user_percent_of_disability
    #   @return [Integer] User percent of disability rating (ex. 90)
    #
    class RatingInfo
      include ActiveModel::Serialization
      include Virtus.model

      attribute :disability_decision_type_name, String
      attribute :service_connected_combined_degree, Integer
      attribute :user_percent_of_disability, Integer
    end
  end
end
