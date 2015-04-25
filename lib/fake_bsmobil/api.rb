require 'fake_bsmobil'

require 'roda'

module FakeBsmobil

  class Api < Roda

    DEFAULT_HEADERS = {
        'Server' => 'BancSabadell',
        'Access-Control-Allow-Credentials' => 'true',
        'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE',
        'Access-Control-Allow-Headers' => 'Content-Type, Accept, Content-Length, Accept-Language',
        'Access-Control-Max-Age' => '1800',
        'Content-Type' => 'application/vnd.idk.bsmobil-v2+json;charset=UTF-8',
        'P3P' => 'CP="NOI DEVa TAIa OUR BUS UNI STA OTC"'
        # TODO: missing caching headers
    }.freeze

    plugin :json

    def validation_error
      {
          error_message: 'Some of the data entered are invalid or a required field is empty. Please check the data and try again.',
          code: ''
      }
    end

    plugin :param_matchers
    plugin :header_matchers
    plugin :hash_matcher
    plugin :cookies
    plugin :error_handler


    def handle_error(exception)
      case exception
        when FakeBsmobil::InvalidInputError
          response.status = exception.status
          response['Content-Type'] = 'application/json'
          response.write exception.to_json
        else raise exception
      end
    end

    hash_matcher :content_type do |v|
      self.content_type == v
    end

    def session_id
      request.cookies['JSESSIONID']
    end

    JSON_TYPE = 'application/json'.freeze

    route do |r|

      def r.post(*args, &block)
        args << { content_type: JSON_TYPE }
        super
      end

      r.on 'bsmobil/api', accept: 'application/vnd.idk.bsmobil-v2+json', header: 'Content-Type' do |content_type|

        response.headers.merge!(DEFAULT_HEADERS)

        r.post 'session' do
          response.status = 201

          begin
            user = FakeBsmobil.session(request.body.read)

            if user
              response.set_cookie 'JSESSIONID', value: FakeBsmobil.session_id, path: '/bsmobil'
              user
            else
              response.status = 500
              { errorMessage: 'Z23226: The USERNAME or ACCESS CODE is incorrect. Please enter details again.', code: '' }
            end
          rescue FakeBsmobil::ValidationError
            validation_error
          end
        end

        unless FakeBsmobil.find_session(session_id)
          response.status = 403
          break { errorMessage: 'Session time out for security. If you wish to re/connect.', code: '' }
        end

        r.post 'activeagent' do
          {
              name: name = Generator.name,
              phone: Generator.phone_number(prefix: nil),
              email: Generator.email(name: name, domain: 'sabadellatlantico.com'),
              office: "0140",
              dni: Generator.dni,
              activeAgent: false,
              picture: '',
              available: true
          }
        end

        r.get 'products' do
          FakeBsmobil.products
        end

        r.on 'accounts' do
          r.is do
            r.get do
              FakeBsmobil.accounts
            end
          end

          r.post 'movements' do
            # request body is :
            # {
            #     "moreRequest": false,
            #     "account": {
            #         "number": "0092-0230-39-0011343732"
            #     },
            #     "dateFrom": "",
            #     "dateTo": ""
            # }
            FakeBsmobil.account_movements(request.body.read)
          end
        end

        r.on 'cards' do

          r.is(param!: :filter) do |filter|
            r.get do
              FakeBsmobil.cards(filter)
            end
          end


          r.on 'movements' do

            r.post 'unconfirmed' do

              # request body is:
              # {"card":{"realNumber":"5402131445633169"}}
              FakeBsmobil.unconfirmed_card_movements(request.body.read)
              # NotFound: { "errorMessage": "Z10570: -", "code": "" }
              # missing realNumber: { "errorMessage": "Z26454: Transaction not carried out. Please contact our Customer Care service.", "code": "" }
              # invalid field: { "errorMessage": "Could not read JSON: Unrecognized field \"realNumberr\"", "code": "" }
            end

            r.post 'confirmed' do
              # request body is:
              # { card: { realNumber: "5402131445633169" }}
              FakeBsmobil.confirmed_card_movements(request.body.read)
            end
          end

        end

      end

    end
  end
end
