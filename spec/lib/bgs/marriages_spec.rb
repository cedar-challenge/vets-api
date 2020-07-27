# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BGS::Marriages do
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
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures', '686c', 'dependents') }
  let(:all_flows_payload) do
    payload = File.read("#{fixtures_path}/all_flows_payload.json")
    JSON.parse(payload)
  end

  describe '#create' do
    context 'adding a spouse' do
      it 'returns hash for spouse who lives with veteran' do
        json = File.read("#{fixtures_path}/spouse/spouse_lives_with_veteran.json")
        payload = JSON.parse(json)

        VCR.use_cassette('bgs/dependents/create/spouse/lives_with_veteran') do
          dependents = BGS::Marriages.new(
            proc_id: proc_id,
            payload: payload,
            user: user_hash
          ).create

          expect(dependents).to include(
            a_hash_including(
              family_relationship_type_name: 'Spouse',
              participant_relationship_type_name: 'Spouse',
              marriage_city: 'Slawson',
              marriage_state: 'CA',
              type: 'spouse',
              begin_date: '2014-03-04'
            )
          )
        end
      end

      it 'returns hash for spouse who has different address (separated)' do
        VCR.use_cassette('bgs/dependents/create') do
          dependents = BGS::Marriages.new(
            proc_id: proc_id,
            payload: all_flows_payload,
            user: user_hash
          ).create

          expect(dependents).to include(
            a_hash_including(
              family_relationship_type_name: 'Estranged Spouse',
              participant_relationship_type_name: 'Spouse',
              marriage_city: 'Slawson',
              marriage_state: 'CA',
              type: 'spouse',
              begin_date: '2014-03-04'
            )
          )
        end
      end

      it 'marks spouse as veteran' do
        json = File.read("#{fixtures_path}/spouse/spouse_is_veteran.json")
        payload = JSON.parse(json)
        spouse_vet_hash = {
          'first' => 'Jenny',
          'middle' => 'Lauren',
          'last' => 'McCarthy',
          'alt_address' => nil,
          'lives_with_vet' => true,
          'suffix' => 'Sr.',
          'ssn' => '323454323',
          'birth_date' => '1981-04-04',
          'ever_married_ind' => 'Y',
          'vet_ind' => 'Y',
          'va_file_number' => '00000000',
          'martl_status_type_cd' => 'Married'
        }

        VCR.use_cassette('bgs/dependents/create/spouse/is_veteran') do
          expect_any_instance_of(BGS::Service).to receive(:create_person)
            .with('3828033', '149487', spouse_vet_hash)
            .and_call_original

          BGS::Marriages.new(
            proc_id: proc_id,
            payload: payload,
            user: user_hash
          ).create
        end
      end
    end
  end
end