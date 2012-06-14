
require 'rest-core/middleware'

require 'restclient/payload'
require 'em-http-request'

class RestCore::EmHttpRequestAsync
  include RestCore::Middleware
  def call env, &k
    payload = ::RestClient::Payload.generate(env[REQUEST_PAYLOAD])
    client  = ::EventMachine::HttpRequest.new(request_uri(env)).send(
                 env[REQUEST_METHOD],
                 :body => payload.read,
                 :head => payload.headers.merge(env[REQUEST_HEADERS]))

    client.callback{ process(env, client, k) }
    client. errback{ process(env, client, k) }

    env[TIMER].on_timeout{
      client.close
      yield(env.merge(RESPONSE_BODY    => env[TIMER].error,
                      RESPONSE_STATUS  => 0               ,
                      RESPONSE_HEADERS => {}             ))
    } if env[TIMER]

    env
  end

  def process env, client, k
    env[TIMER].cancel if env[TIMER] && !env[TIMER].canceled?
    k.call(env.merge(RESPONSE_BODY    => client.response,
                     RESPONSE_STATUS  => client.response_header.status,
                     RESPONSE_HEADERS => client.response_header))
  end
end
