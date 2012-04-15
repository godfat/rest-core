
require 'rest-core/test'

describe RC::JsonRequest do
  before do
    @app = RC::JsonRequest.new(RC::Dry.new, true)
    @env = {RC::REQUEST_HEADERS => {}}
    @request_params = {
      'key' => 'value',
      'array' => [1, 2, 3],
      'nested' => {'k' => 'v', 'a' => [4, 5, 6]}
    }
  end

  should 'add header' do
    @app.call(@env).should.eq(
      RC::REQUEST_HEADERS => {'Content-Type' => 'application/json'},
      RC::REQUEST_PAYLOAD => '{}',
      RC::REQUEST_QUERY   => nil)
  end

  should 'clear query and fill payload by encoded json if GET' do
    @env.merge!(RC::REQUEST_METHOD => :get,
                RC::REQUEST_QUERY => @request_params)

    @app.call(@env).should.eq(
      RC::REQUEST_METHOD => :get,
      RC::REQUEST_HEADERS => {'Content-Type' => 'application/json'},
      RC::REQUEST_PAYLOAD => MultiJson.dump(@request_params),
      RC::REQUEST_QUERY   => nil)
  end

  should 'clear encode payload as json if not GET' do
    @env.merge!(RC::REQUEST_METHOD => :post,
                RC::REQUEST_PAYLOAD => @request_params)

    @app.call(@env).should.eq(
      RC::REQUEST_METHOD => :post,
      RC::REQUEST_HEADERS => {'Content-Type' => 'application/json'},
      RC::REQUEST_PAYLOAD => MultiJson.dump(@request_params),
      RC::REQUEST_QUERY   => nil)
  end
end
