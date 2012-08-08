
require 'rest-core/middleware'

require 'restclient'

require 'rest-core/patch/rest-client'

class RestCore::RestClient
  include RestCore::Middleware
  def call env, &k
    res = ::RestClient::Request.execute(:method  => env[REQUEST_METHOD ],
                                        :url     => request_uri(env)    ,
                                        :payload => env[REQUEST_PAYLOAD],
                                        :headers => env[REQUEST_HEADERS],
                                        :max_redirects => 0)

    process(env, res.body, res.code, normalize_headers(res.raw_headers), k)

  rescue ::RestClient::Exception => e
    if res = e.response
      # we don't want to raise an exception for 404 requests
      process(env, res.body, res.code, normalize_headers(res.raw_headers), k)
    else
      process(env.merge(FAIL => env[FAIL] + [e]), '', 0, {}, k)
    end
  end

  def process env, body, status, headers, k
    k.call(env.merge(RESPONSE_BODY    => body  ,
                     RESPONSE_STATUS  => status,
                     RESPONSE_HEADERS => headers))
  end

  def normalize_headers raw_headers
    raw_headers.inject({}){ |r, (k, v)|
      r[k.to_s.upcase.tr('-', '_')] = if v.kind_of?(Array) && v.size == 1
                                        v.first
                                      else
                                        v
                                      end
      r
    }
  end
end
