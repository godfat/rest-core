
require 'rest-core/test'

describe RestCore::AuthBasic do
  before do
    @auth = RestCore::AuthBasic.new(RestCore::Dry.new, nil, nil)
  end

  should 'do nothing' do
    @auth.call({}).should.eq({})
  end

  should 'send Authorization header' do
    @auth.instance_eval{@username = 'Aladdin'}
    @auth.instance_eval{@password = 'open sesame'}

    @auth.call({}).should.eq({RestCore::REQUEST_HEADERS =>
      {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='}})

    acc = {'Accept' => 'text/plain'}
    env = {RestCore::REQUEST_HEADERS => acc}

    @auth.call(env).should.eq({RestCore::REQUEST_HEADERS =>
      {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='}.merge(acc)})
  end

  should 'leave a log if username are not both provided' do
    @auth.instance_eval{@username = 'Aladdin'}
    @auth.call({})[RestCore::LOG].size.should.eq 1
  end

  should 'leave a log if password are not both provided' do
    @auth.instance_eval{@password = 'open sesame'}
    @auth.call({})[RestCore::LOG].size.should.eq 1
  end
end
