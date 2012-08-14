
require 'rest-core/test'

describe RC::Oauth1Header do
  before do
    @env = {RC::REQUEST_METHOD => :post,
            RC::REQUEST_PATH   =>
              'https://api.twitter.com/oauth/request_token'}

    callback =
    'http://localhost:3005/the_dance/process_callback?service_provider_id=11'

    @oauth_params =
      {'oauth_callback'     => callback                                     ,
       'oauth_consumer_key' => 'GDdmIQH6jhtmLUypg82g'                       ,
       'oauth_nonce'        => 'QP70eNmVz8jvdPevU3oJD2AfF7R7odC2XJcn4XlZJqk',
       'oauth_timestamp'    => '1272323042'                                 ,
       'oauth_version'      => '1.0'                                        ,
       'oauth_signature_method' => 'HMAC-SHA1'}

    @auth = RC::Oauth1Header.new(RC::Dry.new,
      nil, nil, nil,
      'GDdmIQH6jhtmLUypg82g',
      'MCD8BKwGdgPHvAuvgvz4EQpqDAtx89grbuNMRd7Eh98')
  end

  should 'have correct signature' do
    @auth.signature(@env, @oauth_params).should.eq(
      '8wUi7m5HFQy76nowoCThusfgB+Q=')
  end

  describe 'base_string' do
    before do
      @base_string =
        'POST&https%3A%2F%2Fapi.twitter.com%2Foauth%2Frequest_token&' \
        'oauth_callback%3Dhttp%253A%252F%252Flocalhost%253A3005%252F' \
        'the_dance%252Fprocess_callback%253Fservice_provider_id%253D' \
        '11%26oauth_consumer_key%3DGDdmIQH6jhtmLUypg82g%26oauth_nonc' \
        'e%3DQP70eNmVz8jvdPevU3oJD2AfF7R7odC2XJcn4XlZJqk%26oauth_sig' \
        'nature_method%3DHMAC-SHA1%26oauth_timestamp%3D1272323042%26' \
        'oauth_version%3D1.0'
    end

    def check
      @auth.base_string(@env, @oauth_params).should.eq @base_string
    end

    should 'have correct base_string' do
      check
    end

    should 'not use payload in multipart request for base_string' do
      @env.merge!(RC::REQUEST_PAYLOAD => {'file' => File.open(__FILE__)})
      check
    end

    should 'not use payload if it contains binary' do
      @env.merge!(RC::REQUEST_PAYLOAD => File.open(__FILE__))
      check
    end

    should 'not use payload if it contains [binary]' do
      @env.merge!(RC::REQUEST_PAYLOAD => [File.open(__FILE__)])
      check
    end

    should 'not use payload if Content-Type is not x-www-form-urlencoded' do
      @env.merge!(RC::REQUEST_PAYLOAD => {'pay' => 'load'},
                  RC::REQUEST_HEADERS => {'Content-Type' => 'text/plain'})
      check
    end

    should 'use payload if Content-Type is x-www-form-urlencoded' do
      @base_string << '%26pay%3Dload'
      @env.merge!(RC::REQUEST_PAYLOAD => {'pay' => 'load'},
                  RC::REQUEST_HEADERS =>
                    {'Content-Type' => 'application/x-www-form-urlencoded'})
      check
    end

    should 'use payload if there is no binary data' do
      @base_string << '%26pay%3Dload'
      @env.merge!(RC::REQUEST_PAYLOAD => {'pay' => 'load'})
      check
    end

    should 'not escape ~' do
      @base_string << '%26tilde%3D~'
      @env.merge!(RC::REQUEST_PAYLOAD => {'tilde' => '~'})
      check
    end
  end
end
