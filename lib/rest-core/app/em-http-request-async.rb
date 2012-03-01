
require 'rest-core/middleware'

require 'rest-client'
require 'em-http-request'

class RestCore::EmHttpRequestAsync
  include RestCore::Middleware
  def call env
    payload = ::RestClient::Payload.generate(env[REQUEST_PAYLOAD])
    client  = ::EventMachine::HttpRequest.new(request_uri(env)).send(
                 env[REQUEST_METHOD],
                 :body => payload.read,
                 :head => payload.headers.merge(env[REQUEST_HEADERS]))

    client.callback{
      env[TIMER].cancel if env[TIMER]
      env[ASYNC].call(env.merge(
        RESPONSE_BODY    => client.response,
        RESPONSE_STATUS  => client.response_header.status,
        RESPONSE_HEADERS => client.response_header)) if env[ASYNC]
    }

    env[TIMER].on_timeout{
      client.close
      env[ASYNC].call(env.merge(RESPONSE_BODY    => env[TIMER].error,
                                RESPONSE_STATUS  => 0               ,
                                RESPONSE_HEADERS => {}             )) if
         env[ASYNC]
    } if env[TIMER]

    env
  end
end
