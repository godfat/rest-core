
require 'rest-core/middleware'

require 'cool.io-http'

class RestCore::CoolioCallback
  include RestCore::Middleware
  def call env
    client = ::Coolio::Http.request(:method  => env[REQUEST_METHOD] ,
                                    :url     => request_uri(env)    ,
                                    :payload => env[REQUEST_PAYLOAD],
                                    :headers => env[REQUEST_HEADERS]){ |res|

      env[TIMER].detach if env[TIMER]
      env[ASYNC].call(env.merge(RESPONSE_BODY    => res.body  ,
                                RESPONSE_STATUS  => res.status,
                                RESPONSE_HEADERS => res.headers)) if
        env[ASYNC]
    }

    env[TIMER].on_timer{
      detach
      client.detach
      env[ASYNC].call(env.merge(RESPONSE_BODY    => env[TIMER].error,
                                RESPONSE_STATUS  => 0               ,
                                RESPONSE_HEADERS => {}             )) if
         env[ASYNC]
    } if env[TIMER]

    env
  end
end
