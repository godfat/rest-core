
require 'restclient'
require 'rest-core/patch/rest-client'

require 'rest-core/app/future/future'
require 'rest-core/middleware'

class RestCore::RestClient
  include RestCore::Middleware
  def call env, &k
    future  = Future::FutureThread.new(env, k, env[ASYNC])

    Thread.new{
      begin
        res = ::RestClient::Request.execute(:method  => env[REQUEST_METHOD ],
                                            :url     => request_uri(env)    ,
                                            :payload => env[REQUEST_PAYLOAD],
                                            :headers => env[REQUEST_HEADERS],
                                            :max_redirects => 0)
        future.on_load(res.body, res.code, normalize_headers(res.raw_headers))

      rescue ::RestClient::Exception => e
        if res = e.response
          # we don't want to raise an exception for 404 requests
          future.on_load(res.body, res.code,
            normalize_headers(res.raw_headers))
        else
          future.on_error(e)
        end
      end
    }

    env.merge(RESPONSE_BODY    => future.proxy_body,
              RESPONSE_STATUS  => future.proxy_status,
              RESPONSE_HEADERS => future.proxy_headers,
              FUTURE           => future)
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
