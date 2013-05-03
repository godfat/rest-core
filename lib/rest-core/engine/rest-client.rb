
require 'restclient'
require 'rest-core/patch/rest-client'

require 'rest-core/engine/future/future'
require 'rest-core/middleware'

class RestCore::RestClient
  include RestCore::Middleware
  def call env, &k
    future  = Future::FutureThread.new(env, k, env[ASYNC])

    t = future.wrap{ # we can implement thread pool in the future
      begin
        payload = RC::Payload.generate(env[REQUEST_PAYLOAD])
        headers = env[REQUEST_HEADERS].merge(payload.headers)
        res = ::RestClient::Request.execute(:method  => env[REQUEST_METHOD],
                                            :url     => request_uri(env)   ,
                                            :payload => payload            ,
                                            :headers => headers            ,
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
      rescue Exception => e
        future.on_error(e)
      end
    }

    env[TIMER].on_timeout{
      t.kill
      future.on_error(env[TIMER].error)
    } if env[TIMER]

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
