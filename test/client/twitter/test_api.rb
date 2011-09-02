
require 'rest-core/test'

describe RestCore::Twitter do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'get right' do
    stub_request(:get, 'https://api.twitter.com/me').
      to_return(:body => '{"status": "OK"}')

    RestCore::Twitter.new.get('me').should.eq({'status' => 'OK'})
  end

  def check status, klass
    stub_request(:delete, 'https://api.twitter.com/123').to_return(
      :body => '{}', :status => status)

    lambda{
      RestCore::Twitter.new.delete('123')
    }.should.raise(klass)

    WebMock.reset!
  end

  should 'raise exception when encountering error' do
    [401, 402, 403].each{ |status|
      check(status, RestCore::Twitter::Error)
    }

    [500, 502, 503].each{ |status|
      check(status, RestCore::Twitter::Error::ServerError)
    }
  end
end
