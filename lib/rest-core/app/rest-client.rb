
require 'rest-core/middleware'

require 'restclient'

class RestCore::RestClient
  include RestCore::Middleware
  def call env
    response =
      ::RestClient::Request.execute(:method  => env[REQUEST_METHOD ],
                                    :url     => env[REQUEST_URI    ],
                                    :payload => env[REQUEST_PAYLOAD],
                                    :headers => env[REQUEST_HEADERS])

    env.merge(RESPONSE_BODY    => response.body,
              RESPONSE_HEADERS => response.raw_headers)
  rescue ::RestClient::Exception => e
    env.merge(RESPONSE_BODY    => e.response.body,
              RESPONSE_HEADERS => e.response.raw_headers)
  end
end
