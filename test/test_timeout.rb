
require 'rest-core/test'

describe RC::Timeout do
  app = RC::Timeout.new(RC::Dry.new, 0)

  after do
    WebMock.reset!
    Muack.verify
  end

  should 'bypass timeout if timeout is 0' do
    mock(app).monitor.times(0)
    app.call({}){ |e| e.should.eq({}) }
  end

  should 'run the monitor to setup timeout' do
    env = {'timeout' => 2}
    mock_proxy(app).monitor(env).times(1)
    app.call(env){|e| e[RC::TIMER].should.kind_of?(RC::Timeout::TimerThread)}
  end

  should "not raise timeout error if there's already an error" do
    env = {'timeout' => 0.01}
    mock(app.app).call(hash_including(env)){ raise "error" }
    lambda{ app.call(env){} }.should    .raise(RuntimeError)
    lambda{ sleep 0.01      }.should.not.raise(Timeout::Error)
  end
end
