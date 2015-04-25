require 'rack/test'

RSpec.describe FakeBsmobil::Api do
  subject(:app) { described_class.freeze.app }
  include Rack::Test::Methods

  def post(uri, body, env = {})
    super uri, body, env.merge('CONTENT_TYPE' => 'application/json',
                               'HTTP_ACCEPT' => 'application/vnd.idk.bsmobil-v2+json')
  end

  describe 'sessions' do
    it 'returns error on empty user/password' do
      response = post '/bsmobil/api/session', '{"deviceInfo":"iOSNative iPhone 8.2 NATIVE_APP 15.2.0","password":"","userName":"","newDevice":false,"contract":"","brand":"SAB","devicePrint":"","requestId":"SDK","geolocationData":"{\"DeviceSystemVersion\":\"8.2\",\"HardwareID\":\"FAB70832-3893-4471-BC3C-3C984A852E49\",\"ScreenSize\":\"320 x 568\",\"Languages\":\"en\",\"MultitaskingSupported\":true,\"DeviceModel\":\"iPhone\",\"RSA_ApplicationKey\":\"42D7D0F93CE15214780F4DED46BAD347\",\"TIMESTAMP\":\"2015-04-06T10:10:34Z\",\"Emulator\":0,\"OS_ID\":\"46CC0D94-5F6F-44B7-B25D-055A8B093D81\",\"Compromised\":0,\"DeviceSystemName\":\"iPhone OS\",\"DeviceName\":\"bank_scrap\",\"SDK_VERSION\":\"2.0.0\"}","loginType":5}'

      expect(response.body).to eq('{"errorMessage":"Z23226: The USERNAME or ACCESS CODE is incorrect. Please enter details again.","code":""}')
      expect(response.status).to eq(500)
    end

    it 'sets a cookie' do
      response = post '/bsmobil/api/session', '{"deviceInfo":"iOSNative iPhone 8.2 NATIVE_APP 15.2.0","password":"a","userName":"b","newDevice":false,"contract":"","brand":"SAB","devicePrint":"","requestId":"SDK","geolocationData":"{\"DeviceSystemVersion\":\"8.2\",\"HardwareID\":\"FAB70832-3893-4471-BC3C-3C984A852E49\",\"ScreenSize\":\"320 x 568\",\"Languages\":\"en\",\"MultitaskingSupported\":true,\"DeviceModel\":\"iPhone\",\"RSA_ApplicationKey\":\"42D7D0F93CE15214780F4DED46BAD347\",\"TIMESTAMP\":\"2015-04-06T10:10:34Z\",\"Emulator\":0,\"OS_ID\":\"46CC0D94-5F6F-44B7-B25D-055A8B093D81\",\"Compromised\":0,\"DeviceSystemName\":\"iPhone OS\",\"DeviceName\":\"bank_scrap\",\"SDK_VERSION\":\"2.0.0\"}","loginType":5}'

      expect(response.status).to eq(201)
      expect(response.headers['Set-Cookie']).to match(%r{JSESSIONID=.+?; path=/bsmobil})
    end
  end
end
