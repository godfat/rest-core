
require 'rest-core/promise'
require 'rest-core/middleware'

class RestCore::Engine
  def self.members; [:config_engine]; end
  include RestCore::Middleware

  def call env, &k
    promise = Promise.new(env[TIMER])
    req     = env.merge(REQUEST_URI => request_uri(env)).
                  merge(promise.future_response)

    promise.then{ |result| req.merge(result).merge(FAIL => env[FAIL]) }.
            then(&k)
    # case env[CLIENT].pool_size
    # when 0
      promise.defer{ request(req) }
    # else
    #   promise.defer(env[CLIENT].thread_pool){ request(req) }
    # end

    req
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
