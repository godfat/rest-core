
require 'rest-core/test'

describe RestCore::Universal do
  should 'send Authorization header' do
    u = RestCore::Universal.new(:log_method => false)
    u.username = 'Aladdin'
    u.password = 'open sesame'

    u.request_full({}, u.dry)[RestCore::REQUEST_HEADERS].should.eq(
      {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='})

    acc = {'Accept' => 'text/plain'}
    env = {RestCore::REQUEST_HEADERS => acc}

    u.request_full(env, u.dry)[RestCore::REQUEST_HEADERS].should.eq(
      {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='}.merge(acc))
  end
end
