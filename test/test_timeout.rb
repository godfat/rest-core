
require 'rest-core/test'

describe RC::Timeout do
  before do
    @app = RC::Timeout.new(RC::Dry.new, 0)
  end

  after do
    WebMock.reset!
    RR.verify
  end

  should 'bypass timeout if timeout is 0' do
    mock(@app).monitor.times(0)
    @app.call({}){ |e| e.should.eq({}) }
  end

  should 'run the monitor to setup timeout' do
    env = {'timeout' => 2}
    mock.proxy(@app).monitor(env).times(1)
    @app.call(env){|e| e[RC::TIMER].should.kind_of?(RC::Timeout::TimerThread)}
  end
end
