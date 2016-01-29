
require 'rest-core/promise'
require 'rest-core/middleware'
require 'rest-core/util/payload'

module RestCore
  class Engine
    def self.members; [:config_engine]; end
    include RestCore::Middleware

    def call env, &k
      promise = Promise.new(env[TIMER])
      req     = env.merge(REQUEST_URI => request_uri(env), PROMISE => promise)

      promise.then do |result|
        case result
        when Exception
          req.merge(FAIL => env[FAIL] + [result])
        else
          req.merge(result)
        end
      end.then(&k)

      pool_size = env[CLIENT].class.pool_size
      if pool_size < 0
        promise.call{ request(req) }
      elsif pool_size == 0
        promise.defer{ request(req) }
      else
        promise.defer(env[CLIENT].class.thread_pool){ request(req) }
      end

      req.merge(promise.future_response)
    end

    private
    def payload_and_headers env
      if has_payload?(env)
        Payload.generate_with_headers(env[REQUEST_PAYLOAD],
                                      env[REQUEST_HEADERS])
      else
        [{}, env[REQUEST_HEADERS]]
      end
    end

    def normalize_headers headers
      headers.inject({}){ |r, (k, v)|
        r[k.to_s.upcase.tr('-', '_')] = if v.kind_of?(Array) && v.size == 1
                                          v.first
                                        else
                                          v
                                        end
        r
      }
    end
  end
end
