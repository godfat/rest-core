
require 'fiber'

require 'em-http-request'
require 'restclient/payload'

require 'rest-core/app/abstract/response_future'
require 'rest-core/middleware'

class RestCore::EmHttpRequest
  include RestCore::Middleware
  def call env, &k
    payload = ::RestClient::Payload.generate(env[REQUEST_PAYLOAD])
    client  = ::EventMachine::HttpRequest.new(request_uri(env)).send(
                 env[REQUEST_METHOD],
                 :body => payload.read,
                 :head => payload.headers.merge(env[REQUEST_HEADERS]))

    future = ResponseFuture.new(env, k, env[ASYNC])

    client.callback{ process(future, client) }
    client. errback{ process(future, client) }

    env[TIMER].on_timeout{
      (client.instance_variable_get(:@callbacks)||[]).clear
      (client.instance_variable_get(:@errbacks )||[]).clear
      client.close
      future.on_error(env[TIMER].error)
    }

    env.merge(RESPONSE_BODY    => future.proxy_body,
              RESPONSE_STATUS  => future.proxy_status,
              RESPONSE_HEADERS => future.proxy_headers)
  end

  def process future, client
    future.on_load(client.response,
                   client.response_header.status,
                   client.response_header)
  end
end
