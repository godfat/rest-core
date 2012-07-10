
require 'rest-core/test'

describe RC::Timeout do
  before do
    @app = RC::Timeout.new(RC::Dry.new, 0)
  end

  after do
    WebMock.reset!
  end

  should 'bypass timeout if timeout is 0' do
    mock(@app).monitor.times(0)
    @app.call({}){ |e| e.should.eq({}) }
  end

  should 'run the monitor to setup timeout' do
    env = {'timeout' => 2}
    mock.proxy(@app).monitor(env).times(1)
    @app.call(env){ |e| e.should.eq(env) }
  end

  should 'return correct result under fibers' do
    path = 'http://example.com/'
    stub_request(:get, path).to_return(:body => 'response')

    c = RC::Builder.client do
      use RC::Timeout, 10
      run RC::EmHttpRequestFiber
    end.new
    EM.run{Fiber.new{c.get(path).should.eq('response');EM.stop}.resume}
  end if defined?(Fiber)
end
