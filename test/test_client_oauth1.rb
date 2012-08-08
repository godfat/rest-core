
require 'rest-core/test'

describe RC::ClientOauth1 do
  after do
    WebMock.reset!
    RR.verify
  end

  client = RC::Builder.client do
    use RC::Oauth1Header
  end

  client.send(:include, RC::ClientOauth1)

  should 'restore data with correct sig' do
    data = {'a' => 'b', 'c' => 'd'}
    sig = Digest::MD5.hexdigest('e&a=b&c=d')
    data_sig = data.merge('sig' => sig)
    data_json = RC::Json.encode(data_sig)
    @client = client.new(:data => data, :consumer_secret => 'e')

    @client.send(:calculate_sig).should.eq sig
    @client.data_json.should.eq data_json

    @client.data_json = data_json
    @client.data.should.eq data_sig

    @client.data_json = RC::Json.encode(data_sig.merge('sig' => 'wrong'))
    @client.data.should.eq({})

    @client.data_json = data_json
    @client.data.should.eq data_sig

    @client.data_json = 'bad json'
    @client.data.should.eq({})
  end

  should 'have correct default data' do
    @client = client.new
    @client.data.should.eq({})
    @client.data = nil
    @client.data['a'] = 'b'
    @client.data['a'].should.eq 'b'
  end

  should 'authorize' do
    stub_request(:post, 'http://localhost').
      to_return(:body => 'oauth_token=abc')

    stub_request(:post, 'http://nocalhost').
      to_return(:body => 'user_id=123&haha=point')

    @client = client.new(:request_token_path => 'http://localhost',
                         :authorize_path     => 'http://mocalhost',
                         :access_token_path  => 'http://nocalhost')

    @client.authorize_url!.should.eq 'http://mocalhost?oauth_token=abc'
    @client.authorize!.should.eq('user_id' => '123', 'haha' => 'point',
                                 'authorized' => 'true')
  end
end
