
require 'rest-core/middleware'

require 'cool.io-http'

class RestCore::CoolioFiber
  include RestCore::Middleware
  def call env
    process(env,
            ::Coolio::HttpFiber.request(:url     => request_uri(env),
                                        :payload => env[REQUEST_PAYLOAD],
                                        :headers => env[REQUEST_HEADERS]))
  end

  def process env, response
    result = env.merge(RESPONSE_BODY    => response.body  ,
                       RESPONSE_STATUS  => response.status,
                       RESPONSE_HEADERS => response.headers)
    result[ASYNC].call(result) if result[ASYNC]
    result
  end
end
