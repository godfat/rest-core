
require 'rest-core/middleware'

require 'cool.io-http'

class RestCore::Coolio
  include RestCore::Middleware
  def call env
    ::Coolio::Http.request(:url     => request_uri(env),
                           :payload => env[REQUEST_PAYLOAD],
                           :headers => env[REQUEST_HEADERS]){ |response|

      env[ASYNC].call(env.merge(RESPONSE_BODY    => response.body       ,
                                RESPONSE_STATUS  => response.status.to_i,
                                RESPONSE_HEADERS => response.headers))
    }

    env
  end
end