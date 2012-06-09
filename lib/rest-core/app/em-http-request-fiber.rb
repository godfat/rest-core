
require 'rest-core/middleware'

require 'restclient/payload'
require 'em-http-request'
require 'fiber'

class RestCore::EmHttpRequestFiber
  include RestCore::Middleware
  def call env
    f = Fiber.current

    payload = ::RestClient::Payload.generate(env[REQUEST_PAYLOAD])
    client  = ::EventMachine::HttpRequest.new(request_uri(env)).send(
                 env[REQUEST_METHOD],
                 :body => payload.read,
                 :head => payload.headers.merge(env[REQUEST_HEADERS]))

    client.callback{ respond(f, env, client) }
    client. errback{ respond(f, env, client) }

    if (response = Fiber.yield).kind_of?(::Exception)
      client.close
      raise response
    else
      response
    end
  end

  def respond f, env, client
    f.resume(process(env, client)) if f.alive?
  rescue FiberError
    # whenever timeout, client.close would be called,
    # and then errback would be called. in this case,
    # the fiber is already resumed by the timer
  end

  def process env, client
    result = env.merge(RESPONSE_BODY    => client.response,
                       RESPONSE_STATUS  => client.response_header.status,
                       RESPONSE_HEADERS => client.response_header)
    result[ASYNC].call(result) if result[ASYNC]
    result
  end
end
