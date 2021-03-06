# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Facilities::NCAFacility do
  before { BaseFacility.validate_on_load = false }

  after { BaseFacility.validate_on_load = true }

  it 'is an Facilities::NCAFacility object' do
    expect(described_class.new).to be_an(Facilities::NCAFacility)
  end

  describe 'pull_source_data' do
    it 'pulls data from ArcGIS endpoint' do
      VCR.use_cassette('facilities/va/nca_facilities') do
        list = Facilities::NCAFacility.pull_source_data
        expect(list.size).to eq(10)
      end
    end

    it 'returns an array of Facilities::NCAFacility objects' do
      VCR.use_cassette('facilities/va/nca_facilities') do
        list = Facilities::NCAFacility.pull_source_data
        expect(list).to be_an(Array)
        expect(list.all? { |item| item.is_a?(Facilities::NCAFacility) }).to be true
      end
    end

    context 'with single facility' do
      let(:facilities) { Facilities::NCAFacility.pull_source_data }
      let(:facility) { facilities.first }

      it 'gets the correct classification name' do
        VCR.use_cassette('facilities/va/nca_facilities') do
          expect(facility.classification).to eq('Soldiers Lot')
        end
      end

      it 'includes websites for facilities' do
        VCR.use_cassette('facilities/va/nca_facilities') do
          expect(facility.website).to eq('https://www.cem.va.gov/cems/lots/baxtersprings.asp')
        end
      end
    end
  end
end
