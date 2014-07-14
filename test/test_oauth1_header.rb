
require 'rest-core/test'

describe RC::Oauth1Header do
  env = {RC::REQUEST_METHOD  => :post,
         RC::REQUEST_PATH    =>
           'https://api.twitter.com/oauth/request_token',
         RC::REQUEST_QUERY   => {},
         RC::REQUEST_PAYLOAD => {}}

  callback =
    'http://localhost:3005/the_dance/process_callback?service_provider_id=11'

  oauth_params =
    {'oauth_callback'     => callback                                     ,
     'oauth_consumer_key' => 'GDdmIQH6jhtmLUypg82g'                       ,
     'oauth_nonce'        => 'QP70eNmVz8jvdPevU3oJD2AfF7R7odC2XJcn4XlZJqk',
     'oauth_timestamp'    => '1272323042'                                 ,
     'oauth_version'      => '1.0'                                        ,
     'oauth_signature_method' => 'HMAC-SHA1'}

  auth = RC::Oauth1Header.new(RC::Dry.new,
    nil, nil, nil,
    'GDdmIQH6jhtmLUypg82g',
    'MCD8BKwGdgPHvAuvgvz4EQpqDAtx89grbuNMRd7Eh98')

  would 'have correct signature' do
    auth.signature(env, oauth_params).should.eq(
      '8wUi7m5HFQy76nowoCThusfgB+Q=')
  end

  describe 'base_string' do
    base_string =
      'POST&https%3A%2F%2Fapi.twitter.com%2Foauth%2Frequest_token&' \
      'oauth_callback%3Dhttp%253A%252F%252Flocalhost%253A3005%252F' \
      'the_dance%252Fprocess_callback%253Fservice_provider_id%253D' \
      '11%26oauth_consumer_key%3DGDdmIQH6jhtmLUypg82g%26oauth_nonc' \
      'e%3DQP70eNmVz8jvdPevU3oJD2AfF7R7odC2XJcn4XlZJqk%26oauth_sig' \
      'nature_method%3DHMAC-SHA1%26oauth_timestamp%3D1272323042%26' \
      'oauth_version%3D1.0'

    check = lambda do |e, b|
      auth.base_string(e, oauth_params).should.eq b
    end

    would 'have correct base_string' do
      check[env, base_string]
    end

    would 'not use payload in multipart request for base_string' do
      File.open(__FILE__) do |f|
        check[env.merge(RC::REQUEST_PAYLOAD => {'file' => f}), base_string]
      end
    end

    would 'not use payload if it contains binary' do
      File.open(__FILE__) do |f|
        check[env.merge(RC::REQUEST_PAYLOAD => f), base_string]
      end
    end

    would 'not use payload if it contains [binary]' do
      File.open(__FILE__) do |f|
        check[env.merge(RC::REQUEST_PAYLOAD => [f]), base_string]
      end
    end

    would 'not use payload if Content-Type is not x-www-form-urlencoded' do
      check[
        env.merge(RC::REQUEST_PAYLOAD => {'pay' => 'load'},
                  RC::REQUEST_HEADERS => {'Content-Type' => 'text/plain'}),
        base_string]
    end

    would 'use payload if Content-Type is x-www-form-urlencoded' do
      check[env.merge(
              RC::REQUEST_PAYLOAD => {'pay' => 'load'},
              RC::REQUEST_HEADERS =>
                {'Content-Type' => 'application/x-www-form-urlencoded'}),
            base_string + '%26pay%3Dload']
    end

    would 'use payload if there is no binary data' do
      check[env.merge(RC::REQUEST_PAYLOAD => {'pay' => 'load'}),
            base_string + '%26pay%3Dload']
    end

    would 'not escape ~' do
      check[env.merge(RC::REQUEST_PAYLOAD => {'tilde' => '~'}),
            base_string + '%26tilde%3D~']
    end
  end
end
