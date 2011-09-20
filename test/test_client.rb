
require 'rest-core/test'

describe RestCore::Simple do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'do simple request' do
    stub_request(:get, 'http://localhost/').to_return(:body => '[]')
    RestCore::Simple.new.get('http://localhost/').should.eq '[]'
  end

  should 'use defaults' do
    client = RestCore::Builder.client do
      s = self.class # this is only for ruby 1.8!
      use s::Timeout, 4
    end
    c = client.new
    c.timeout.should.eq 4 # default goes to middleware
    client.extend(Module.new do
      def default_timeout
        3
      end
    end)
    c.timeout.should.eq 4 # default is cached, so it stays the same
    c.timeout = nil       # clear cache
    c.timeout.should.eq 3 # now default goes to module default
    class << client
      def default_timeout # module defaults could be overriden
        super - 1
      end
    end
    c.timeout = nil
    c.timeout.should.eq 2 # so it goes to class default
    c.timeout = 1         # setup instance level value
    c.build_env(                )['timeout'].should.eq 1 # pick instance var
    c.build_env({'timeout' => 0})['timeout'].should.eq 0 # per-request var
    c.timeout.should.eq 1 # won't affect underlying instance var
    c.timeout = nil
    c.timeout.should.eq 2 # goes back to class default
    c.timeout = false
    c.timeout.should.eq false # false would disable default
  end
end
