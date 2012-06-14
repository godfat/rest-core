
require 'rest-core/app/abstract/response_thunk'
require 'rest-core/middleware'

require 'restclient/payload'
require 'em-http-request'

class RestCore::EmHttpRequestThunk
  include RestCore::Middleware
  def call env, &k
    payload = ::RestClient::Payload.generate(env[REQUEST_PAYLOAD])
    client  = ::EventMachine::HttpRequest.new(request_uri(env)).send(
                 env[REQUEST_METHOD],
                 :body => payload.read,
                 :head => payload.headers.merge(env[REQUEST_HEADERS]))

    thunk = ResponseThunk.new(env, k)

    client.callback{ process(thunk, client) }
    client. errback{ process(thunk, client) }

    env.merge(RESPONSE_BODY    => thunk.proxy_body,
              RESPONSE_STATUS  => thunk.proxy_status,
              RESPONSE_HEADERS => thunk.proxy_headers)
  end

  def process thunk, client
    thunk.on_load(client.response,
                  client.response_header.status,
                  client.response_header)
  end
end
