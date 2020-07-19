# frozen_string_literal: true

require 'bgs/exceptions/service_exception'

module BGS
  class Service
    include SentryLogging
    MAX_ATTEMPTS = 3

    def initialize(user)
      @user = user
    end

    def create_participant(proc_id, corp_ptcpnt_id = nil)
      with_multiple_attempts_enabled do
        service.vnp_ptcpnt.vnp_ptcpnt_create(
          {
            vnp_proc_id: proc_id,
            ptcpnt_type_nm: 'Person',
            corp_ptcpnt_id: corp_ptcpnt_id
          }.merge(bgs_auth)
        )
      end
    end

    def create_person(proc_id, participant_id, payload)
      with_multiple_attempts_enabled do
        service.vnp_person.vnp_person_create(
          create_person_params(proc_id, participant_id, payload)
        )
      end
    end

    def create_address(proc_id, participant_id, payload)
      with_multiple_attempts_enabled do
        service.vnp_ptcpnt_addrs.vnp_ptcpnt_addrs_create(
          create_address_params(proc_id, participant_id, payload)
        )
      end
    end

    def create_phone(proc_id, participant_id, payload)
      with_multiple_attempts_enabled do
        service.vnp_ptcpnt_phone.vnp_ptcpnt_phone_create(
          {
            vnp_proc_id: proc_id,
            vnp_ptcpnt_id: participant_id,
            phone_type_nm: 'Daytime',
            phone_nbr: payload['phone_number'],
            efctv_dt: Time.current.iso8601
          }.merge(bgs_auth)
        )
      end
    end

    def service
      @service ||= BGS::Services.new(
        external_uid: @user[:icn],
        external_key: @user[:external_key]
      )
    end

    private

    def create_address_params(proc_id, participant_id, payload)
      {
        efctv_dt: Time.current.iso8601,
        vnp_ptcpnt_id: participant_id,
        vnp_proc_id: proc_id,
        ptcpnt_addrs_type_nm: 'Mailing',
        shared_addrs_ind: 'N',
        addrs_one_txt: payload['address_line1'],
        addrs_two_txt: payload['address_line2'],
        addrs_three_txt: payload['address_line3'],
        city_nm: payload['city'],
        cntry_nm: payload['country_name'],
        postal_cd: payload['state_code'],
        mlty_postal_type_cd: payload['military_postal_code'],
        mlty_post_office_type_cd: payload['military_post_office_type_code'],
        zip_prefix_nbr: payload['zip_code'],
        prvnc_nm: payload['state_code'],
        email_addrs_txt: payload['email_address']
      }.merge(bgs_auth)
    end

    def create_person_params(proc_id, participant_id, payload)
      {
        vnp_proc_id: proc_id,
        vnp_ptcpnt_id: participant_id,
        first_nm: payload['first'],
        middle_nm: payload['middle'],
        last_nm: payload['last'],
        suffix_nm: payload['suffix'],
        brthdy_dt: format_date(payload['birth_date']),
        birth_state_cd: payload['place_of_birth_state'],
        birth_city_nm: payload['place_of_birth_city'],
        file_nbr: payload['va_file_number'],
        ssn_nbr: payload['ssn'],
        death_dt: format_date(payload['death_date']),
        ever_maried_ind: payload['ever_married_ind'],
        vet_ind: payload['vet_ind'],
        martl_status_type_cd: 'Married'
      }.merge(bgs_auth)
    end

    def with_multiple_attempts_enabled
      attempt ||= 0
      yield
    rescue => e
      attempt += 1
      if attempt < MAX_ATTEMPTS
        notify_of_service_exception(e, __method__.to_s, attempt, :warn)
        retry
      else
        notify_of_service_exception(e, __method__.to_s)
      end
    end

    def bgs_auth
      {
        jrn_dt: Time.current.iso8601,
        jrn_lctn_id: Settings.bgs.client_station_id,
        jrn_status_type_cd: 'U',
        jrn_user_id: Settings.bgs.client_username,
        jrn_obj_id: Settings.bgs.application,
        ssn: @user[:ssn] # Just here to make the mocks work
      }
    end

    def notify_of_service_exception(error, method, attempt = nil, status = :error)
      msg = "Unable to #{method}: #{error.message}: try #{attempt} of #{MAX_ATTEMPTS}"
      context = { icn: @user[:icn] }
      tags = { team: 'vfs-ebenefits' }

      return log_message_to_sentry(msg, :warn, context, tags) if status == :warn

      log_exception_to_sentry(error, context, tags)
      raise_backend_exception('BGS_686c_SERVICE_403', self.class, error)
    end

    def raise_backend_exception(key, source, error)
      exception = BGS::ServiceException.new(
        key,
        { source: source.to_s },
        403,
        error.message
      )

      raise exception
    end

    def format_date(date)
      return nil if date.nil?

      Date.parse(date).to_time.iso8601
    end
  end
end