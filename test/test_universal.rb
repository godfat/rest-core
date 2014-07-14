
require 'rest-core/test'

describe RC::Universal do
  would 'send Authorization header' do
    u = RC::Universal.new(:log_method => false)
    u.username = 'Aladdin'
    u.password = 'open sesame'

    u.request_full({}, u.dry)[RC::REQUEST_HEADERS].should.eq(
      {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='})

    acc = {'Accept' => 'text/plain'}
    env = {RC::REQUEST_HEADERS => acc}

    u.request_full(env, u.dry)[RC::REQUEST_HEADERS].should.eq(
      {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='}.merge(acc))
  end

  would 'clash' do
    url = 'http://localhost/'
    stub_request(:get, url).to_return(:body => '{"a":{"b":"c"}}')
    res = RC::Universal.new(:json_response => true,
                            :clash_response => true,
                            :log_method => false).get(url)
    res['a']['d'].should.eq({})
  end
end
