# frozen_string_literal: true

module ClaimsApi
  module V0
    class ClaimsControllerSwagger
      include Swagger::Blocks

      swagger_path '/claims/{id}' do
        operation :get do
          security do
            key :apikey, []
          end
          key :summary, 'Find Claim by ID'
          key :description, 'Returns a single claim if the user has access'
          key :operationId, 'findClaimById'
          key :tags, [
            'Claims'
          ]

          parameter do
            key :name, :id
            key :in, :path
            key :description, 'The ID of the claim being requested'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-SSN'
            key :in, :header
            key :description, 'SSN of Veteran to fetch'
            key :example, '123121234'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-First-Name'
            key :in, :header
            key :description, 'First Name of Veteran to fetch'
            key :example, 'John'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-Last-Name'
            key :in, :header
            key :description, 'Last Name of Veteran to fetch'
            key :example, 'Doe'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-Birth-Date'
            key :in, :header
            key :description, 'Date of Birth of Veteran to fetch in iso8601 format'
            key :example, '1954-12-15'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-EDIPI'
            key :in, :header
            key :description, 'EDIPI Number of Veteran to fetch'
            key :required, false
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-User'
            key :in, :header
            key :description, 'VA username of the person making the request'
            key :example, 'lighthouse'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-LOA'
            key :in, :header
            key :description, 'The level of assurance of the user making the request'
            key :example, '3'
            key :required, true
            key :type, :string
          end

          response 200 do
            key :description, 'claims response'
            schema do
              key :type, :object
              key :required, [:data]
              property :data do
                key :'$ref', :ClaimsShow
              end
            end
          end

          response :default do
            key :description, 'unexpected error'
            schema do
              key :type, :object
              key :required, [:errors]
              property :errors do
                key :type, :array
                items do
                  key :'$ref', :ErrorModel
                end
              end
            end
          end
        end
      end

      swagger_path '/claims' do
        operation :get do
          security do
            key :apikey, []
          end

          key :summary, 'All Claims'
          key :description, 'Returns all claims from the system that the user has access to'
          key :operationId, 'findClaims'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Claims'
          ]

          parameter do
            key :name, 'X-VA-SSN'
            key :in, :header
            key :description, 'SSN of Veteran to fetch'
            key :example, '123121234'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-First-Name'
            key :in, :header
            key :description, 'First Name of Veteran to fetch'
            key :example, 'John'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-Last-Name'
            key :in, :header
            key :description, 'Last Name of Veteran to fetch'
            key :example, 'Doe'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-Birth-Date'
            key :in, :header
            key :description, 'Date of Birth of Veteran to fetch in iso8601 format'
            key :example, '1954-12-15'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-EDIPI'
            key :in, :header
            key :description, 'EDIPI Number of Veteran to fetch'
            key :required, false
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-User'
            key :in, :header
            key :description, 'VA username of the person making the request'
            key :example, 'lighthouse'
            key :required, false
            key :type, :string
          end

          parameter do
            key :name, 'X-VA-LOA'
            key :in, :header
            key :description, 'The level of assurance of the user making the request'
            key :example, '3'
            key :required, true
            key :type, :string
          end

          response 200 do
            key :description, 'claim response'
            schema do
              key :type, :object
              key :required, [:data]
              property :data do
                key :type, :array
                items do
                  key :'$ref', :ClaimsIndex
                end
              end
            end
          end

          response :default do
            key :description, 'unexpected error'
            schema do
              key :type, :object
              key :required, [:errors]
              property :errors do
                key :type, :array
                items do
                  key :'$ref', :ErrorModel
                end
              end
            end
          end
        end
      end
    end
  end
end
