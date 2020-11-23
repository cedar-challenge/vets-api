# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V0::PreferredFacilitiesController, type: :controller do
  let(:user) { create(:user, :loa3, :accountable) }

  before do
    sign_in_as(user)
  end

  describe '#index' do
    before do
      create(:preferred_facility)
      create(:preferred_facility, user: user)
      create(:preferred_facility, facility_code: '688', user: user)
    end

    it 'lists a users preferred facilities' do
      get(:index)

      expect(
        JSON.parse(response.body)['data'].map do |preferred_facility_data|
          preferred_facility_data['attributes']
        end
      ).to eq(
        [
          { 'facility_code' => '983' },
          { 'facility_code' => '688' },
        ]
      )
    end
  end
end
