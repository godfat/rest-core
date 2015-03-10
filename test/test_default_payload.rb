
require 'rest-core/test'

describe RC::DefaultPayload do
  app = RC::DefaultPayload.new(RC::Dry.new, {})
  env = {RC::REQUEST_PAYLOAD => {}}

  before do
    app.instance_eval{@payload = {}}
  end

  would 'do nothing' do
    app.call(env){ |r| r[RC::REQUEST_PAYLOAD].should.eq({}) }
  end

  would 'merge payload' do
    app.instance_eval{@payload = {'pay' => 'load'}}

    app.call(env){ |r| r.should.eq({RC::REQUEST_PAYLOAD =>
      {'pay' => 'load'}}) }

    format = {'format' => 'json'}
    e      = {RC::REQUEST_PAYLOAD => format}

    app.call(e){ |r| r.should.eq({RC::REQUEST_PAYLOAD =>
      {'pay' => 'load'}.merge(format)})}
  end

  would 'also merge the very default payload' do
    a = RC::DefaultPayload.new(RC::Dry.new, 'a' => 'b')
    a.call('payload' => {'b' => 'c'},
           RC::REQUEST_PAYLOAD => {'c' => 'd'}) do |r|
      r[RC::REQUEST_PAYLOAD].should.eq 'a' => 'b', 'b' => 'c', 'c' => 'd'
    end
  end

  would 'accept non-hash payload' do
    u = RC::Universal.new(:log_method => false)
    e = {RC::REQUEST_PAYLOAD => 'payload'}
    u.request_full(e, u.dry)[RC::REQUEST_PAYLOAD].should.eq('payload')

    u.payload = 'default'
    u.request_full( e, u.dry)[RC::REQUEST_PAYLOAD].should.eq('payload')
    u.request_full({}, u.dry)[RC::REQUEST_PAYLOAD].should.eq('default')

    u = RC::Builder.client{use RC::DefaultPayload, 'maylord'}.new
    u.request_full({}, u.dry)[RC::REQUEST_PAYLOAD].should.eq('maylord')
    u.request_full( e, u.dry)[RC::REQUEST_PAYLOAD].should.eq('payload')
  end
end
