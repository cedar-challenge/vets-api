# frozen_string_literal: true

module HealthQuest
  module V0
    class PGDQuestionnaireSerializer
      include FastJsonapi::ObjectSerializer

      set_type :questionnaire

      attributes :text
    end
  end
end
