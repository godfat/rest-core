
require 'rest-core/middleware'

require 'restclient'

class RestCore::RestClient
  include RestCore::Middleware
  def call env
    respond(env,
            ::RestClient::Request.execute(:method  => env[REQUEST_METHOD ],
                                          :url     => request_uri(env)    ,
                                          :payload => env[REQUEST_PAYLOAD],
                                          :headers => env[REQUEST_HEADERS]))

  rescue ::RestClient::Exception => e
    respond(env, e.response)
  end

  def respond env, response
    env.merge(RESPONSE_BODY    => response.body,
              RESPONSE_STATUS  => response.code,
              RESPONSE_HEADERS => response.raw_headers)
  end
end
