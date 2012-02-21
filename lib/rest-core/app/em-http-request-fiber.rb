
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
      env[TIMER].cancel if env[TIMER]
      f.resume(process(env, client)) if f.alive?
    }

    if (response = Fiber.yield).kind_of?(::Exception)
      client.close
      raise response
    else
      response
    end
  end

  def process env, client
    result = env.merge(RESPONSE_BODY    => client.response,
                       RESPONSE_STATUS  => client.response_header.status,
                       RESPONSE_HEADERS => client.response_header)
    result[ASYNC].call(result) if result[ASYNC]
    result
  end
end
