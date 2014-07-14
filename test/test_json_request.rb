
require 'rest-core/test'

describe RC::JsonRequest do
  app = RC::JsonRequest.new(RC::Dry.new, true)
  env = {RC::REQUEST_HEADERS => {}}
  request_params = {
    'key' => 'value',
    'array' => [1, 2, 3],
    'nested' => {'k' => 'v', 'a' => [4, 5, 6]}
  }

  would 'encode payload as json' do
    e = env.merge(RC::REQUEST_METHOD  => :post,
                  RC::REQUEST_PAYLOAD => request_params)

    app.call(e){ |res|
      res.should.eq(
        RC::REQUEST_METHOD  => :post,
        RC::REQUEST_HEADERS => {'Content-Type' => 'application/json'},
        RC::REQUEST_PAYLOAD => RC::Json.encode(request_params))}
  end

  would 'do nothing if json_request is false' do
    app = RC::JsonRequest.new(RC::Dry.new, false)
    app.call(env){ |res| res.should.eq res }
  end
end
