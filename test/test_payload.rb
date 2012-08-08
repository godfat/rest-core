
require 'rest-core/test'

describe RC::DefaultPayload do
  app = RC::DefaultPayload.new(RC::Dry.new, {})

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

  should 'accept non-hash payload' do
    u = RC::Universal.new(:log_method => false)
    env = {RC::REQUEST_PAYLOAD => 'payload'}
    u.request_full(env, u.dry)[RC::REQUEST_PAYLOAD].should.eq('payload')

    u.payload = 'default'
    u.request_full(env, u.dry)[RC::REQUEST_PAYLOAD].should.eq('payload')
    u.request_full({} , u.dry)[RC::REQUEST_PAYLOAD].should.eq('default')

    u = RC::Builder.client{use RC::DefaultPayload, 'maylord'}.new
    u.request_full({} , u.dry)[RC::REQUEST_PAYLOAD].should.eq('maylord')
    u.request_full(env, u.dry)[RC::REQUEST_PAYLOAD].should.eq('payload')
  end
end
