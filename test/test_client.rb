
require 'rest-core/test'

describe RC::Simple do
  after do
    WebMock.reset!
    Muack.verify
  end

  should 'do simple request' do
    url = 'http://localhost/'
    [:get, :post, :delete, :put, :patch, :options].each do |method|
      stub_request(method, url).to_return(:body => '[]')
      RC::Simple.new.send(method, url).should.eq '[]'
    end

    stub_request(:head, url).to_return(:headers => {'A' => 'B'})
    RC::Simple.new.head(url).should.eq({'A' => 'B'})
  end

  should 'call the callback' do
    url = 'http://localhost/'
    [:get, :post, :delete, :put, :patch, :options].each do |method|
      stub_request(method, url).to_return(:body => '123')
      (client = RC::Simple.new).send(method, url){ |res|
        res.should.eq '123' }.should.eq client
      client.wait
    end

    stub_request(:head, url).to_return(:headers => {'A' => 'B'})
    (client = RC::Simple.new).head(url){ |res|
      res.should.eq({'A' => 'B'})
    }.should.eq client
    client.wait
  end

  should 'have correct to_i' do
    stub_request(:get, 'http://localhost/').to_return(:body => '123')
    RC::Simple.new.get('http://localhost/').to_i.should.eq 123
  end

  should 'use defaults' do
    client = RC::Builder.client do
      use RC::Timeout, 4
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
