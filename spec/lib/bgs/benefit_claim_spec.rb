# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BGS::BenefitClaim do
  let(:user_object) { FactoryBot.create(:evss_user, :loa3) }
  let(:user_hash) do
    {
      participant_id: user_object.participant_id,
      ssn: user_object.ssn,
      first_name: user_object.first_name,
      last_name: user_object.last_name,
      external_key: user_object.common_name || user_object.email,
      icn: user_object.icn
    }
  end
  let(:proc_id) { '3828033' }
  let(:participant_id) { '146189' }
  let(:vet_hash) do
    {
      file_number: user_hash[:ssn],
      vnp_participant_id: user_hash[:participant_id],
      ssn_number: user_hash[:ssn],
      benefit_claim_type_end_product: '133',
      first_name: user_hash[:first_name],
      last_name: user_hash[:last_name],
      vnp_participant_address_id: '113372',
      phone_number: '5555555555',
      address_line_one: '123 Mainstreet',
      address_state_code: 'FL',
      address_country: 'USA',
      address_city: 'Tampa',
      address_zip_code: '22145',
      email_address: 'foo@foo.com'
    }
  end

  describe '#create' do
    it 'returns a BenefitClaim hash' do
      VCR.use_cassette('bgs/benefit_claim/create') do
        benefit_claim = BGS::BenefitClaim.new(
          vnp_benefit_claim: { vnp_benefit_claim_type_code: '130DPNEBNADJ' },
          veteran: vet_hash,
          user: user_hash
        ).create

        expect(benefit_claim).to include(
          {
            benefit_claim_id: '600196508',
            claim_type_code: '130DPNEBNADJ',
            participant_claimant_id: '600061742',
            program_type_code: 'CPL',
            service_type_code: 'CP',
            status_type_code: 'PEND'
          }
        )
      end
    end

    it 'calls BGS::Service#insert_benefit_claim' do
      VCR.use_cassette('bgs/benefit_claim/create') do
        expect_any_instance_of(BGS::BenefitClaimWebService).to receive(:insert_benefit_claim)
          .with(
            a_hash_including(
              {
                ptcpnt_id_claimant: '600061742',
                ssn: '796043735',
                file_number: '796043735',
                date_of_claim: '07/19/2020',
                end_product: '133',
                end_product_code: '130DPNEBNADJ',
                end_product_name: '130 - Automated Dependency 686c',
                first_name: 'WESLEY',
                last_name: 'FORD',
                payee: '00'
              }
            )
          )
          .and_call_original

        BGS::BenefitClaim.new(
          vnp_benefit_claim: { vnp_benefit_claim_type_code: '130DPNEBNADJ' },
          veteran: vet_hash,
          user: user_hash
        ).create
      end
    end
  end
end