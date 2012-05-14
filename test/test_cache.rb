
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
          env.merge(RC::RESPONSE_BODY => 'response')
        end
      }
    end.new
    c.get('/')
    c.cache.should.eq({Digest::MD5.hexdigest('/') => 'response'})
    c.app.app.tick.should.eq 1
    c.get('/')
    c.app.app.tick.should.eq 1
    c.cache.clear
    c.get('/')
    c.app.app.tick.should.eq 2
  end

  should 'cancel timeout for fiber' do
    path = 'http://example.com/'
    any_instance_of(RC::Timeout::EventMachineTimer) do |timer|
      proxy.mock(timer).cancel.times(2)
    end
    stub_request(:get, path).to_return(:body => 'response')
    c = RC::Builder.client do
      use RC::Timeout, 10
      use RC::Cache, {}, 3600
      run RC::EmHttpRequestFiber
    end.new
    EM.run{ Fiber.new{
      c.request_full(RC::REQUEST_PATH => path)
      c.request_full(RC::REQUEST_PATH => path)
      EM.stop }.resume }
    c.cache.size.should.eq 1
  end if defined?(Fiber)

  should 'cancel timeout for async' do
    path = 'http://example.com/'
    any_instance_of(RC::Timeout::EventMachineTimer) do |timer|
      mock(timer).cancel.times(2)
    end
    stub_request(:get, path).to_return(:body => 'response')
    c = RC::Builder.client do
      use RC::Timeout, 10
      use RC::Cache, {}, 3600
      run RC::EmHttpRequestAsync
    end.new
    EM.run{
      c.request_full(RC::REQUEST_PATH => path){
        c.request_full(RC::REQUEST_PATH => path){
          EM.stop }}}
    c.cache.size.should.eq 1
  end
end
