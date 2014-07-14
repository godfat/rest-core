
require 'rest-core/test'

describe RC::Oauth2Header do
  env  = {RC::REQUEST_HEADERS => {}}
  auth = RC::Oauth2Header.new(RC::Dry.new)

  would 'do nothing if no access token' do
    auth.call(env){ |res| res.should.eq(env) }
  end

  would 'Bearer token' do
    auth.call(env.merge('access_token_type' => 'Bearer',
                        'access_token'      => 'token')){ |res|
      res[RC::REQUEST_HEADERS].should.eq 'Authorization' => 'Bearer token'
    }
  end

  would 'MAC token' do # http://tools.ietf.org/html/rfc6749#section-7.1
    auth.call(env.merge('access_token_type' => 'MAC',
                        'access_token'      =>
                          {'id'  => 'h480djs93hd8',
                           'mac' => 'kDZvddkndxv='})){ |res|
      res[RC::REQUEST_HEADERS].should.eq \
        'Authorization' => 'MAC id="h480djs93hd8", mac="kDZvddkndxv="'
    }
  end
end
