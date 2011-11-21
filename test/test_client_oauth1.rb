
require 'rest-core/test'

describe RC::ClientOauth1 do
  client = RC::Builder.client do
    s = self.class # this is only for ruby 1.8!
    use s::Oauth1Header
  end

  client.send(:include, RC::ClientOauth1)

  should 'restore data with correct sig' do
    data = {'a' => 'b', 'c' => 'd'}
    sig = Digest::MD5.hexdigest('e&a=b&c=d')
    data_sig = data.merge('sig' => sig)
    data_json = RC::JsonDecode.json_encode(data_sig)
    @client = client.new(:data => data, :consumer_secret => 'e')

    @client.send(:calculate_sig).should.eq sig
    @client.data_json.should.eq data_json

    @client.data_json = data_json
    @client.data.should.eq data_sig

    @client.data_json = RC::JsonDecode.json_encode(
      data_sig.merge('sig' => 'wrong'))
    @client.data.should.eq({})

    @client.data_json = data_json
    @client.data.should.eq data_sig

    @client.data_json = ['bad json']
    @client.data.should.eq({})
  end

  should 'have correct default data' do
    @client = client.new
    @client.data.should.eq({})
    @client.data = nil
    @client.data['a'] = 'b'
    @client.data['a'].should.eq 'b'
  end
end
