
require 'rest-core/test'

describe RC::Timeout do
  before do
    @app = RC::Timeout.new(RC::Dry.new, 0)
  end

  should 'bypass timeout if timeout is 0' do
    mock(@app).monitor.times(0)
    @app.call({}).should.eq({})
  end

  should 'run the monitor to setup timeout' do
    env = {'timeout' => 2}
    mock.proxy(@app).monitor(env).times(1)
    @app.call(env).should.eq(env)
  end
end
