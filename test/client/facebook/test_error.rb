
require 'rest-core/test'

describe RestCore::Facebook::Error do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'have the right ancestors' do
    RestCore::Facebook::Error::AccessToken.should.lt RestCore::Facebook::Error

    RestCore::Facebook::Error::InvalidAccessToken.should.lt \
      RestCore::Facebook::Error::AccessToken

    RestCore::Facebook::Error::MissingAccessToken.should.lt \
      RestCore::Facebook::Error::AccessToken
  end

  def error2env hash
    {RestCore::RESPONSE_BODY => hash,
     RestCore::REQUEST_PATH  => '/' ,
     RestCore::REQUEST_QUERY => {}}
  end

  should 'parse right' do
    %w[OAuthInvalidTokenException OAuthException].each{ |type|
      RestCore::Facebook::Error.call(error2env('error' => {'type' => type})).
        should.kind_of?(RestCore::Facebook::Error::InvalidAccessToken)
    }

    RestCore::Facebook::Error.call(
      error2env('error'=>{'type'   =>'QueryParseException',
                          'message'=>'An active access token..'})).
      should.kind_of?(RestCore::Facebook::Error::MissingAccessToken)

    RestCore::Facebook::Error.call(
      error2env('error'=>{'type'   =>'QueryParseException',
                          'message'=>'Oh active access token..'})).
      should.not.kind_of?(RestCore::Facebook::Error::MissingAccessToken)

    RestCore::Facebook::Error.call(error2env('error_code' => 190)).
      should.kind_of?(RestCore::Facebook::Error::InvalidAccessToken)

    RestCore::Facebook::Error.call(error2env('error_code' => 104)).
      should.kind_of?(RestCore::Facebook::Error::MissingAccessToken)

    RestCore::Facebook::Error.call(error2env('error_code' => 999)).
      should.not.kind_of?(RestCore::Facebook::Error::AccessToken)

    error = RestCore::Facebook::Error.call(error2env(['not a hash']))
    error.should.not.kind_of?(RestCore::Facebook::Error::AccessToken)
    error.should    .kind_of?(RestCore::Facebook::Error)
  end

  should 'nuke cache upon errors' do
    stub_request(:get, 'https://graph.facebook.com/me').
      to_return(:body => '{"error":"wrong"}').times(2)

    rg = RestCore::Facebook.new(:cache         => {},
                                :error_handler => lambda{|env|env})
    rg.get('me'); rg.get('me')
    rg.cache.values.should.eq []
  end
end
