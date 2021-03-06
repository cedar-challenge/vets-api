# frozen_string_literal: true

module VAOS
  class JwtWrapper
    VERSION = 2.1
    ISS = 'gov.va.vaos'
    ID_TYPE = 'ICN'
    AUTHORITY = 'gov.va.iam.ssoe.v1'

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def token
      @token ||= JWT.encode(payload, Configuration.instance.rsa_key, 'RS512')
    end

    private

    def payload
      {
        authenticated: true,
        sub: icn,
        idType: ID_TYPE,
        iss: ISS,
        firstName: first_name,
        lastName: last_name,
        authenticationAuthority: AUTHORITY,
        jti: SecureRandom.uuid,
        nbf: 1.minute.ago.to_i,
        exp: 15.minutes.from_now.to_i,
        sst: 1.minute.ago.to_i + 50,
        version: VERSION,
        gender: gender,
        dob: dob,
        dateOfBirth: dob,
        edipid: edipi,
        ssn: ssn
      }
    end

    def icn
      user.icn
    end

    def first_name
      user.mpi&.profile&.given_names&.first
    end

    def last_name
      user.mpi&.profile&.family_name
    end

    def gender
      type = user.mpi&.profile&.gender
      return '' unless type.is_a?(String)

      case type.upcase[0, 1]
      when 'M'
        'MALE'
      when 'F'
        'FEMALE'
      end
    end

    def dob
      user.mpi&.profile&.birth_date
    end

    def edipi
      user.mpi&.profile&.edipi
    end

    def ssn
      user.mpi&.profile&.ssn
    end
  end
end
