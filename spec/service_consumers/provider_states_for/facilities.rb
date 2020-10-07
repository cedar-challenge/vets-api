# frozen_string_literal: true

Pact.provider_states_for 'Facility Locator' do
  provider_state 'ccp data exists' do
    vcr_options = {
      match_requests_on: %i[path query],
      allow_playback_repeats: true
    }
    set_up do
      Flipper.enable(:facility_locator_ppms_location_query, false)
      VCR.insert_cassette('facilities/ppms/ppms', vcr_options)
    end

    tear_down do
       VCR.eject_cassette('facilities/ppms/ppms')
    end
  end

  provider_state 'mashup urgent care data exists' do
    vcr_options = {
      match_requests_on: %i[path query],
      allow_playback_repeats: true
    }
    set_up do
      Flipper.enable(:facility_locator_ppms_location_query, false)
      VCR.insert_cassette('facilities/va/ppms_and_lighthouse', vcr_options)
    end

    tear_down do
       VCR.eject_cassette('facilities/va/ppms_and_lighthouse')
    end
  end

  provider_state 'va data exists' do
    vcr_options = {
      match_requests_on: %i[path query],
      allow_playback_repeats: true
    }
    set_up do
      Flipper.enable(:facility_locator_ppms_location_query, false)
      VCR.insert_cassette('/lighthouse/facilities', vcr_options)
    end

    tear_down do
       VCR.eject_cassette('/lighthouse/facilities')
    end
  end

  provider_state 'ccp specialties data exists' do
    vcr_options = {
      match_requests_on: %i[path query],
      allow_playback_repeats: true
    }
    set_up do
      Flipper.enable(:facility_locator_ppms_location_query, false)
      VCR.insert_cassette('facilities/ppms/ppms', vcr_options)
    end

    tear_down do
       VCR.eject_cassette('facilities/ppms/ppms')
    end
  end

end