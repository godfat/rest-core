
require 'rest-core/test'

describe RC::AuthBasic do
  before do
    @auth = RC::AuthBasic.new(RC::Identity.new, nil, nil)
  end

  env = {RC::REQUEST_HEADERS => {}}

  would 'do nothing' do
    @auth.call({}){ |res| res.should.eq({}) }
  end

  would 'send Authorization header' do
    @auth.instance_eval{@username = 'Aladdin'}
    @auth.instance_eval{@password = 'open sesame'}

    @auth.call(env){ |res|
      res.should.eq(RC::REQUEST_HEADERS =>
        {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='})
    }

    acc = {'Accept' => 'text/plain'}
    env = {RC::REQUEST_HEADERS => acc}

    @auth.call(env){ |res|
      res.should.eq({RC::REQUEST_HEADERS =>
        {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='}.merge(acc)})
    }
  end

  would 'leave a log if username are not both provided' do
    @auth.instance_eval{@username = 'Aladdin'}
    @auth.call(env){ |res| res[RC::LOG].size.should.eq 1 }
  end

  would 'leave a log if password are not both provided' do
    @auth.instance_eval{@password = 'open sesame'}
    @auth.call(env){ |res| res[RC::LOG].size.should.eq 1 }
  end
end
