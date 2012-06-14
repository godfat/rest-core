
require 'rest-core/middleware'

require 'restclient/payload'
require 'em-http-request'
require 'fiber'

class RestCore::EmHttpRequestFiber
  include RestCore::Middleware
  def call env, &k
    f = Fiber.current

    payload = ::RestClient::Payload.generate(env[REQUEST_PAYLOAD])
    client  = ::EventMachine::HttpRequest.new(request_uri(env)).send(
                 env[REQUEST_METHOD],
                 :body => payload.read,
                 :head => payload.headers.merge(env[REQUEST_HEADERS]))

    client.callback{ process(f, env, client) }
    client. errback{ process(f, env, client) }

    if (exception = Fiber.yield).kind_of?(::Exception)
      client.close
      raise exception
    else
      yield(env.merge(RESPONSE_BODY    => client.response,
                      RESPONSE_STATUS  => client.response_header.status,
                      RESPONSE_HEADERS => client.response_header))
    end
  end

  def process f, env, client
    f.resume if f.alive?
  rescue FiberError
    # whenever timeout, client.close would be called,
    # and then errback would be called. in this case,
    # the fiber is already resumed by the timer
  end
end
