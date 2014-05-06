
require 'rest-core/promise'
require 'rest-core/middleware'

class RestCore::Engine
  include RestCore::Middleware

  def call env, &k
    req     = env.merge(REQUEST_URI => request_uri(env))
    promise = Promise.new(req, k, req[ASYNC])
    promise.defer{ request(promise, req) }
    req.merge(RESPONSE_BODY    => promise.future_body,
              RESPONSE_STATUS  => promise.future_status,
              RESPONSE_HEADERS => promise.future_headers,
              RESPONSE_SOCKET  => promise.future_socket,
              FAIL             => promise.future_failures,
              PROMISE          => promise)
  end

  private
  def payload_and_headers env
    Payload.generate_with_headers(env[REQUEST_PAYLOAD], env[REQUEST_HEADERS])
  end

  def calculate_timeout timer
    return [] unless timer
    [timer.timeout, timer.timeout]
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
