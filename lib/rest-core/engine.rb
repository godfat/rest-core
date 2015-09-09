
require 'rest-core/promise'
require 'rest-core/middleware'

class RestCore::Engine
  def self.members; [:config_engine]; end
  include RestCore::Middleware

  def call env, &k
    req     = env.merge(REQUEST_URI => request_uri(env))
    promise = Promise.new(req, k, req[ASYNC])
    promise.defer{ request(promise, req) }
    promise.future_response
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
