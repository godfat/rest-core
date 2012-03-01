
require 'rest-core/middleware'

require 'restclient'

require 'rest-core/patch/rest-client'

class RestCore::RestClient
  include RestCore::Middleware
  def call env
    process(env,
            ::RestClient::Request.execute(:method  => env[REQUEST_METHOD ],
                                          :url     => request_uri(env)    ,
                                          :payload => env[REQUEST_PAYLOAD],
                                          :headers => env[REQUEST_HEADERS],
                                          :max_redirects => 0))

  rescue ::RestClient::Exception => e
    process(env, e.response)
  end

  def process env, response
    result = env.merge(RESPONSE_BODY    => response.body,
                       RESPONSE_STATUS  => response.code,
                       RESPONSE_HEADERS => response.raw_headers)
    result[ASYNC].call(result) if result[ASYNC]
    result
  end
end
