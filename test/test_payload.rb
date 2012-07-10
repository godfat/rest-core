
require 'rest-core/test'

describe RC::DefaultPayload do
  before do
    @app = RC::DefaultPayload.new(RC::Dry.new, {})
  end

  def app
    @app
  end

  should 'do nothing' do
    app.call({}){ |r| r[RC::REQUEST_PAYLOAD].should.eq({}) }
  end

  should 'merge payload' do
    app.instance_eval{@payload = {'pay' => 'load'}}

    app.call({}){ |r| r.should.eq({RC::REQUEST_PAYLOAD =>
      {'pay' => 'load'}}) }

    format = {'format' => 'json'}
    env    = {RC::REQUEST_PAYLOAD => format}

    app.call(env){ |r| r.should.eq({RC::REQUEST_PAYLOAD =>
      {'pay' => 'load'}.merge(format)})}
  end
end
