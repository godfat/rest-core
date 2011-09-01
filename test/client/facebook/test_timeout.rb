
require 'rest-core/test'

describe RestCore::Facebook do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'respect timeout' do
    stub_request(:get, 'https://graph.facebook.com/me').
      to_return(:body => '{}')
    mock.proxy(Timeout).timeout(numeric)
    RestCore::Facebook.new.get('me').should.eq({})
  end

  should 'override timeout' do
    mock(Timeout).timeout(99){ {RestCore::Facebook::RESPONSE_BODY => true} }
    RestCore::Facebook.new(:timeout => 1).get('me', {}, :timeout => 99).
      should.eq true
  end
end
