# frozen_string_literal: true

require 'rails_helper'

describe AppealsApi::DecisionReviewReportJob, type: :job do
  describe '#perform' do
    it 'sends mail' do
      Timecop.freeze
      date_to = Time.zone.now
      date_from = date_to.monday? ? 7.days.ago : 1.day.ago

      expect(AppealsApi::DecisionReviewMailer).to receive(:build).once.with(
        date_from: date_from,
        date_to: date_to
      ).and_return(double.tap do |mailer|
        expect(mailer).to receive(:deliver_now).once
      end)

      described_class.new.perform

      Timecop.return
    end
  end
end
