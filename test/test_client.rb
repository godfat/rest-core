
require 'rest-core/test'

describe RC::Simple do
  after do
    WebMock.reset!
    Muack.verify
  end

  url = 'http://localhost/'

  would 'do simple request' do
    c = RC::Simple.new
    [:get, :post, :delete, :put, :patch].each do |method|
      stub_request(method, url).to_return(:body => '[]')
      c.send(method, url).should.eq '[]'
    end

    stub_request(:head   , url).to_return(:headers => {'A' => 'B'})
    c.   head(url).should.eq('A' => 'B')

    stub_request(:options, url).to_return(:headers => {'A' => 'B'})
    c.options(url).should.eq('A' => 'B')
  end

  would 'call the callback' do
    [:get, :post, :delete, :put, :patch].each do |method|
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

    stub_request(:options, url).to_return(:headers => {'A' => 'B'})
    (client = RC::Simple.new).options(url){ |res|
      res.should.eq('A' => 'B')
    }.should.eq client
    client.wait
  end

  would 'wait for all the requests' do
    t, i, m = 5, 0, Mutex.new
    stub_request(:get, url).to_return do
      m.synchronize{ i += 1 }
      Thread.pass
    end

    client = RC::Builder.client
    t.times{ client.new.get(url) }
    client.wait
    client.promises.should.empty?
    i.should.eq t
  end

  would 'wait for callback' do
    rd, wr = IO.pipe
    called = false
    stub_request(:get, url).to_return(:body => 'nnf')
    client = RC::Builder.client.new.get(url) do |nnf|
      wr.puts
      sleep 0.001 # make sure our callback is slow enough,
                  # so that if `wait` is not waiting for the callback,
                  # it would leave before the callback is completely done.
                  # without sleeping, the callback is very likely to be
                  # done first than `wait` anyway. raising the sleeping time
                  # would make this test more reliable...
      called = true
      nil # test against returning nil, so that Promise#response is not set
    end
    rd.gets
    client.wait
    called.should.eq true
  end

  would 'cleanup promises' do
    stub_request(:get, url)
    client = RC::Builder.client
    5.times{ client.new.get(url) }
    Thread.pass
    GC.start # can only force GC run on MRI, so we mock for jruby and rubinius
    stub(any_instance_of(WeakRef)).weakref_alive?{false}
    client.new.get(url)
    client.promises.size.should.lt 6
    client.shutdown
    client.promises.should.empty?
  end

  would 'have correct to_i' do
    stub_request(:get, url).to_return(:body => '123')
    RC::Simple.new.get(url).to_i.should.eq 123
  end

  would 'use defaults' do
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

  would 'work for inheritance' do
    stub_request(:get, url).to_return(:body => '123')
    Class.new(RC::Simple).new.get(url).should.eq '123'
  end
end
