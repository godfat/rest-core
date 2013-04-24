
require 'em-http-request'
require 'restclient/payload'

require 'rest-core/engine/future/future'
require 'rest-core/middleware'

class RestCore::EmHttpRequest
  include RestCore::Middleware
  def call env, &k
    future  = Future.create(env, k, env[ASYNC])
    payload = ::RestClient::Payload.generate(env[REQUEST_PAYLOAD])
    client  = ::EventMachine::HttpRequest.new(request_uri(env)).send(
                 env[REQUEST_METHOD],
                 :body => payload && payload.read,
                 :head => payload && payload.headers.
                                               merge(env[REQUEST_HEADERS]))

    client.callback{
      future.on_load(client.response,
                     client.response_header.status,
                     client.response_header)}

    client.errback{
      close(client)
      future.on_error(client.error)}

    env[TIMER].on_timeout{
      close(client)
      future.on_error(env[TIMER].error)
    } if env[TIMER]

    env.merge(RESPONSE_BODY    => future.proxy_body,
              RESPONSE_STATUS  => future.proxy_status,
              RESPONSE_HEADERS => future.proxy_headers,
              FUTURE           => future)
  end

  def close client
    (client.instance_variable_get(:@callbacks)||[]).clear
    (client.instance_variable_get(:@errbacks )||[]).clear
    client.close
  end
end
