
require 'rest-core/test'

describe RC::ClientOauth1 do
  after do
    WebMock.reset!
    Muack.verify
  end

  client = RC::Builder.client do
    use RC::Oauth1Header
  end

  client.send(:include, RC::ClientOauth1)

  would 'restore data with correct sig' do
    data = {'a' => 'b', 'c' => 'd'}
    sig = Digest::MD5.hexdigest('e&a=b&c=d')
    data_sig = data.merge('sig' => sig)
    data_json = RC::Json.encode(data_sig)
    c = client.new(:data => data, :consumer_secret => 'e')

    c.send(:calculate_sig).should.eq sig
    c.data_json.should.eq data_json

    c.data_json = data_json
    c.data.should.eq data_sig

    c.data_json = RC::Json.encode(data_sig.merge('sig' => 'wrong'))
    c.data.should.eq({})

    c.data_json = data_json
    c.data.should.eq data_sig

    c.data_json = 'bad json'
    c.data.should.eq({})
  end

  would 'have correct default data' do
    c = client.new
    c.data.should.eq({})
    c.data = nil
    c.data['a'] = 'b'
    c.data['a'].should.eq 'b'
  end

  would 'authorize' do
    stub_request(:post, 'http://localhost').
      to_return(:body => 'oauth_token=abc')

    stub_request(:post, 'http://nocalhost').
      to_return(:body => 'user_id=123&haha=point')

    c = client.new(:request_token_path => 'http://localhost',
                   :authorize_path     => 'http://mocalhost',
                   :access_token_path  => 'http://nocalhost')

    c.authorize_url!.should.eq 'http://mocalhost?oauth_token=abc'
    c.authorize!.should.eq('user_id' => '123', 'haha' => 'point',
                           'authorized' => 'true')
  end
end
