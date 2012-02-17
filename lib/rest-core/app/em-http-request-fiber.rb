
require 'rest-core/middleware'

require 'em-http-request'
require 'fiber'

class RestCore::EmHttpRequestFiber
  include RestCore::Middleware
  def call env
    f = Fiber.current
    client = EventMachine::HttpRequest.new(request_uri(env)).send(
      env[REQUEST_METHOD], :body => env[REQUEST_PAYLOAD],
                           :head => env[REQUEST_HEADERS])
    client.callback{
      f.resume(process(env, client))
    }
    Fiber.yield
  end

  def process env, client
    result = env.merge(RESPONSE_BODY    => client.response,
                       RESPONSE_STATUS  => client.response_header.status,
                       RESPONSE_HEADERS => client.response_header)
    result[ASYNC].call(result) if result[ASYNC]
    result
  end
end
