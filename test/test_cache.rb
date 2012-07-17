
require 'rest-core/test'

describe RC::Cache do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'basic' do
    c = RC::Builder.client do
      use RC::Cache, {}, 3600
      run Class.new{
        attr_accessor :tick
        def initialize
          self.tick = 0
        end
        def call env
          self.tick +=1
          yield(env.merge(RC::RESPONSE_BODY    => 'response',
                          RC::RESPONSE_HEADERS => {'A' => 'B'},
                          RC::RESPONSE_STATUS  => 200))
        end
      }
    end.new
    c.get('/')
    key = Digest::MD5.hexdigest('/')
    c.cache.should.eq("get:#{RC::RESPONSE_BODY}:#{key}"    => 'response',
                      "get:#{RC::RESPONSE_HEADERS}:#{key}" => 'A: B',
                      "get:#{RC::RESPONSE_STATUS}:#{key}"  => '200')
    c.app.app.tick.should.eq 1
    c.get('/')
    c.app.app.tick.should.eq 1
    c.cache.clear
    c.get('/')
    c.app.app.tick.should.eq 2
    c.head('/').should.eq('A' => 'B')
    c.get('/').should.eq 'response'
    c.request({RC::REQUEST_PATH => '/'}, RC::RESPONSE_STATUS).should.eq 200
  end

  should 'head then get' do
    c = RC::Builder.client do
      use RC::Cache, {}, nil
    end.new
    path = 'http://example.com'
    stub_request(:head, path).to_return(:headers => {'A' => 'B'})
    c.head(path).should.eq('A' => 'B')
    stub_request(:get , path).to_return(:body => 'body')
    c.get(path).should.eq('body')
  end

  should 'cancel timeout for fiber' do
    any_instance_of(RC::Timeout::EventMachineTimer) do |timer|
      proxy.mock(timer).cancel.times(2)
    end
    path = 'http://example.com/'
    stub_request(:get, path).to_return(:body => 'response')
    c = RC::Builder.client do
      use RC::Timeout, 10
      use RC::Cache, {}, 3600
      run RC::EmHttpRequest
    end.new
    EM.run{ Fiber.new{
      c.request(RC::REQUEST_PATH => path).should.eq 'response'
      c.request(RC::REQUEST_PATH => path).should.eq 'response'
      EM.stop }.resume }
    c.cache.size.should.eq 3
  end

  should 'cancel timeout for async' do
    path = 'http://example.com/'
    any_instance_of(RC::Timeout::EventMachineTimer) do |timer|
      mock(timer).cancel.times(2)
    end
    stub_request(:get, path).to_return(:body => 'response')
    c = RC::Builder.client do
      use RC::Timeout, 10
      use RC::Cache, {}, 3600
      run RC::EmHttpRequest
    end.new
    EM.run{
      c.request_full(RC::REQUEST_PATH => path){
        c.request_full(RC::REQUEST_PATH => path){
          EM.stop }}}
    c.cache.size.should.eq 3
  end

  should 'only [] and []= should be implemented' do
    cache = Class.new do
      def initialize    ; @h = {}            ; end
      def []  key       ; @h[key]            ; end
      def []= key, value; @h[key] = value * 2; end
    end.new
    c = RC::Builder.client do
      use RC::Cache, cache, 0
      run Class.new{
        def call env
          yield(env.merge(RC::RESPONSE_BODY   => env[RC::REQUEST_PATH],
                          RC::RESPONSE_STATUS => 200))
        end
      }
    end.new
    c.get('4')
    c.get('4').should.eq '44'
  end

  should 'cache the original response' do
    c = RC::Builder.client do
      use RC::Cache, {}, 3600 do
        use RC::JsonDecode, true
      end
    end.new
    stub_request(:get, 'me').to_return(:body => '[]')
    c.get('me').should.eq []
    c.cache.values.first.should.eq '[]'
  end
end
