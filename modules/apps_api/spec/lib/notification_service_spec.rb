# frozen_string_literal: true

require 'rails_helper'
require 'apps_api/notification_service'
require 'ostruct'

describe AppsApi::NotificationService do
  subject { AppsApi::NotificationService.new }

  let(:invalid_connection_event) do
    {
      'actor' => {
        'id' => '1234',
        'type' => 'User',
        'alternateId' => '',
        'displayName' => 'John Doe',
        'detailEntry' => nil
      },
      'client' => {},
      'authenticationContext' => {},
      'displayMessage' => 'Consent granted',
      'eventType' => 'app.oauth2.as.consent.grant',
      'outcome' => {
        'result' => 'FAILED',
        'reason' => ''
      },

      'published' => '2020-10-01T17:37:49.538Z',
      'securityContext' => {},
      'severity' => 'INFO',
      'debugContext' => {},
      'legacyEventType' => 'app.oauth2.as.consent.grant_success',
      'transaction' => {},
      'uuid' => '{event_id}',
      'version' => '0',
      'request' => {},
      'target' => [
        {
          'id' => 'oagke4gvwYHTncxlI2p6',
          'type' => 'ConsentGrant',
          'alternateId' => nil,
          'displayName' => 'veteran_status.read',
          'detailEntry' => {
            'publicclientapp' => '{app_id}',
            'authorizationserver' => '{auth_server_id}',
            'user' => '{user_id}'
          }
        }
      ]
    }
  end

  let(:valid_connection_event) do
    {
      'actor' => {
        'id' => '1234',
        'type' => 'User',
        'alternateId' => '',
        'displayName' => 'John Doe',
        'detailEntry' => nil
      },
      'client' => {},
      'authenticationContext' => {},
      'displayMessage' => 'Consent granted',
      'eventType' => 'app.oauth2.as.consent.grant',
      'outcome' => {
        'result' => 'SUCCESS',
        'reason' => ''
      },
      'published' => '2020-10-01T17:37:49.538Z',
      'securityContext' => {},
      'severity' => 'INFO',
      'debugContext' => {},
      'legacyEventType' => 'app.oauth2.as.consent.grant_success',
      'transaction' => {},
      'uuid' => '{event_id}',
      'version' => '0',
      'request' => {},
      'target' => [
        {
          'id' => 'oagke4gvwYHTncxlI2p6',
          'type' => 'ConsentGrant',
          'alternateId' => nil,
          'displayName' => 'veteran_status.read',
          'detailEntry' => {
            'publicclientapp' => '{app_id}',
            'authorizationserver' => '{auth_server_id}',
            'user' => '{user_id}'
          }
        }
      ]
    }
  end
  let(:invalid_disconnection_event) do
    {
      'actor' => {
        'id' => '{app_id}',
        'type' => 'PublicClientApp',
        'alternateId' => '',
        'displayName' => 'LibertyITCrochet-2020-05-18T14=>48=>22.744Z',
        'detailEntry' => nil
      },
      'client' => {},
      'authenticationContext' => {},
      'displayMessage' => 'OAuth2 token revocation request',
      'eventType' => 'app.oauth2.as.token.revoke',
      'outcome' => {
        'result' => 'SUCCESS',
        'reason' => nil
      },
      'published' => '2020-10-08T18=>08=>41.204Z',
      'securityContext' => {},
      'severity' => 'INFO',
      'debugContext' => {},
      'legacyEventType' => 'app.oauth2.as.token.revoke_success',
      'transaction' => {},
      'uuid' => 'XXYYZZ',
      'version' => '0',
      'request' => {},
      'target' => [
        {
          'id' => '{token_id}',
          'type' => 'access_token',
          'alternateId' => nil,
          'displayName' => 'Access Token',
          'detailEntry' => {
            'expires' => '2020-10-08T19:04:32.000Z',
            'subject' => nil,
            'hash' => ''
          }
        }
      ]
    }
  end
  let(:valid_disconnection_event) do
    {
      'actor' => {
        'id' => '{app_id}',
        'type' => 'PublicClientApp',
        'alternateId' => '',
        'displayName' => 'test',
        'detailEntry' => nil
      },
      'client' => {},
      'authenticationContext' => {},
      'displayMessage' => 'OAuth2 token revocation request',
      'eventType' => 'app.oauth2.as.token.revoke',
      'outcome' => {
        'result' => 'SUCCESS',
        'reason' => nil
      },
      'published' => '2020-10-08T18=>08=>41.204Z',
      'securityContext' => {},
      'severity' => 'INFO',
      'debugContext' => {},
      'legacyEventType' => 'app.oauth2.as.token.revoke_success',
      'transaction' => {},
      'uuid' => 'XXYYZZ',
      'version' => '0',
      'request' => {},
      'target' => [
        {
          'id' => '{token_id}',
          'type' => 'access_token',
          'alternateId' => nil,
          'displayName' => 'Access Token',
          'detailEntry' => {
            'expires' => '2020-10-08T19:04:32.000Z',
            'subject' => '00u7wxd79anps3KjF2p7',
            'hash' => ''
          }
        }
      ]
    }
  end
  let(:user) do
    # only using the portion of the user response needed in the method
    {
      body: {
        'profile' => {
          'firstName' => 'John',
          'lastName' => 'Doe',
          'email' => 'johndoe@email.com'
        }
      }
    }
  end

  # creating an OpenStruct from a hash to mock an Okta::Response with
  # a response body accessible with dot notation
  # IE: user.body['profile']['email']
  let(:user_struct) { OpenStruct.new(user) }
  let(:directory_app) do
    DirectoryApplication.create(name: 'test', logo_url: '123.com',
                                app_type: 'X', service_categories: ['1'],
                                platforms: ['1'], app_url: '123.com',
                                description: 'test', privacy_url: '123.com',
                                tos_url: '123.com')
  end

  let(:published) { '2020-10-08T18=>08=>41.204' }
  let(:returned_hash) do
    subject.create_hash(
      app_record: directory_app,
      user: user_struct,
      published: published
    )
  end
  let(:directory_app_struct) do
    OpenStruct.new(
      # only using the portion of the app response needed in the method
      {
        body: {
          'label' => 'test_label'
        }
      }
    )
  end

  describe '#initialize' do
    it 'initializes the class correctly' do
      expect(subject.instance_variable_get(:@okta_service)).to be_instance_of(Okta::Service)
      expect(subject.instance_variable_get(:@notify_client)).to be_instance_of(VaNotify::Service)
      expect(subject.instance_variable_get(:@connection_event)).to be('app.oauth2.as.consent.grant')
      expect(subject.instance_variable_get(:@disconnection_event)).to be('app.oauth2.as.token.revoke')
    end
  end

  describe 'handle_event' do
    it 'properly calls the okta service' do
      response = OpenStruct.new(
        {
          body:
            [
              valid_connection_event,
              invalid_connection_event
            ]
        }
      )
      allow_any_instance_of(Okta::Service).to receive(:system_logs).with(any_args).and_return(response)
      allow_any_instance_of(Okta::Service).to receive(:app).with(any_args).and_return(directory_app_struct)
      allow_any_instance_of(Okta::Service).to receive(:user).with(any_args).and_return(user_struct)

      expect_any_instance_of(Okta::Service).to receive(:system_logs)
      subject.handle_event(
        subject.instance_variable_get(:@connection_event),
        subject.instance_variable_get(:@connection_template)
      )
    end
  end

  describe 'parse_event' do
    before do
      directory_app
      allow_any_instance_of(Okta::Service).to receive(:user).and_return(user_struct)
      allow_any_instance_of(Okta::Service).to receive(:app).and_return(directory_app_struct)
    end

    it 'calls Okta::Service.user' do
      VCR.use_cassette('okta/user', match_requests_on: %i[method path]) do
        expect_any_instance_of(Okta::Service).to receive(:user)
        subject.parse_event(valid_connection_event)
      end
    end

    it 'invokes create_hash' do
      VCR.use_cassette('okta/user', match_requests_on: %i[method path]) do
        expect_any_instance_of(AppsApi::NotificationService).to receive(:create_hash)
        subject.parse_event(valid_disconnection_event)
      end
    end
  end

  describe 'get_events' do
    before do
      # to ensure our vcr has data in the response
      Timecop.freeze('2020-12-23T19:47:05Z')
      subject.instance_variable_set(:@time_period, 5.days.ago.utc.iso8601)
    end

    it 'returns a response body of connections' do
      VCR.use_cassette('okta/connection_logs', match_requests_on: %i[method path]) do
        response = subject.get_events('app.oauth2.as.consent.grant')
        expect(response.body).not_to be_empty
      end
    end
    it 'returns a response body of disconnections' do
      VCR.use_cassette('okta/disconnection_logs', match_requests_on: %i[method]) do
        response = subject.get_events('app.oauth2.as.token.revoke')
        expect(response.body).not_to be_empty
      end
    end
  end

  describe 'validating events' do
    context 'and the event is a connection' do
      it 'does not validate invalid connection events' do
        expect(subject.event_is_invalid(invalid_connection_event)).to be(true)
      end

      it 'validates valid connection events' do
        expect(subject.event_is_invalid(valid_connection_event)).to be(false)
      end
    end

    context 'and the event is a disconnection' do
      it 'does not validate invalid disconnection events' do
        expect(subject.event_is_invalid(invalid_disconnection_event)).to be(true)
      end

      it 'validates valid disconnection events' do
        expect(subject.event_is_invalid(valid_disconnection_event)).to be(false)
      end
    end
  end

  describe 'create_hash' do
    it 'creates the hash in the correct schema' do
      expect(returned_hash['app_record']).not_to be(nil)
      expect(returned_hash['user_email']).to eq('johndoe@email.com')
      expect(returned_hash['options'].size).to eq(6)
      expect(returned_hash['options']['full_name']).to eq('John Doe')
      expect(returned_hash['options']['time']).to eq('2020-10-08T18=>08=>41.204')
      expect(returned_hash['options']['privacy_policy']).to eq('123.com')
    end
  end

  describe 'send_email' do
    context 'when app_record is nil' do
      let(:hash_with_nil_record) do
        subject.create_hash(
          app_record: nil,
          user: user_struct,
          published: '2020-10-08T18=>08=>41.204'
        )
      end

      it 'returns false' do
        expect(
          subject.send_email(
            hash: hash_with_nil_record,
            template: subject.instance_variable_get(:@connection_template)
          )
        ).to be(false)
      end
    end

    context 'when app_record is not nil' do
      it 'does call the notify client' do
        allow_any_instance_of(VaNotify::Service).to receive(:send_email).and_return(true)
        expect(
          subject.send_email(
            hash: returned_hash,
            template: subject.instance_variable_get(:@connection_template)
          )
        ).to eq(true)
      end
    end
  end
end
