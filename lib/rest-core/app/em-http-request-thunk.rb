
require 'rest-core/app/abstract/response_thunk'
require 'rest-core/middleware'

require 'restclient/payload'
require 'em-http-request'

class RestCore::EmHttpRequestThunk
  include RestCore::Middleware
  def call env
    payload = ::RestClient::Payload.generate(env[REQUEST_PAYLOAD])
    client  = ::EventMachine::HttpRequest.new(request_uri(env)).send(
                 env[REQUEST_METHOD],
                 :body => payload.read,
                 :head => payload.headers.merge(env[REQUEST_HEADERS]))

    thunk = ResponseThunk.new(env)

    client.callback{
      thunk.on_load(client.response,
                    client.response_header.status,
                    client.response_header)
    }

    env.merge(RESPONSE_BODY    => thunk.proxy_body,
              RESPONSE_STATUS  => thunk.proxy_status,
              RESPONSE_HEADERS => thunk.proxy_headers)
  end
end
