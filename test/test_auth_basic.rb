
require 'rest-core/test'

describe RC::AuthBasic do
  before do
    @auth = RC::AuthBasic.new(RC::Dry.new, nil, nil)
  end

  should 'do nothing' do
    @auth.call({}){ |res| res.should.eq({}) }
  end

  should 'send Authorization header' do
    @auth.instance_eval{@username = 'Aladdin'}
    @auth.instance_eval{@password = 'open sesame'}

    @auth.call({}){ |res|
      res.should.eq({RC::REQUEST_HEADERS =>
        {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='}})
    }

    acc = {'Accept' => 'text/plain'}
    env = {RC::REQUEST_HEADERS => acc}

    @auth.call(env){ |res|
      res.should.eq({RC::REQUEST_HEADERS =>
        {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='}.merge(acc)})
    }
  end

  should 'leave a log if username are not both provided' do
    @auth.instance_eval{@username = 'Aladdin'}
    @auth.call({}){ |res| res[RC::LOG].size.should.eq 1 }
  end

  should 'leave a log if password are not both provided' do
    @auth.instance_eval{@password = 'open sesame'}
    @auth.call({}){ |res| res[RC::LOG].size.should.eq 1 }
  end
end
