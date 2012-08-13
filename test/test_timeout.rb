
require 'rest-core/test'

describe RC::Timeout do
  after do
    WebMock.reset!
    RR.verify
  end

  def setup_app
    RC::Timeout.new(RC::Dry.new, 0)
  end

  should 'bypass timeout if timeout is 0' do
    app = setup_app
    mock(app).monitor.times(0)
    app.call({}){ |e| e.should.eq({}) }
  end

  should 'run the monitor to setup timeout' do
    app = setup_app
    env = {'timeout' => 2}
    mock.proxy(app).monitor(env).times(1)
    app.call(env){|e| e[RC::TIMER].should.kind_of?(RC::Timeout::TimerThread)}
  end
end
