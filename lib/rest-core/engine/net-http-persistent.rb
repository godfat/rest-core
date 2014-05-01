
require 'net/http/persistent'

require 'rest-core/engine/dry'
require 'rest-core/promise'
require 'rest-core/middleware'

class RestCore::NetHttpPersistent < RestCore::Dry
  include RestCore::Middleware
  def call env, &k
    promise = Promise.new(env, k, env[ASYNC])
    promise.defer{ request(promise, env) }

    env[TIMER].on_timeout{
      promise.reject(env[TIMER].error)
    } if env[TIMER]

    env.merge(RESPONSE_BODY    => promise.future_body,
              RESPONSE_STATUS  => promise.future_status,
              RESPONSE_HEADERS => promise.future_headers,
              FAIL             => promise.future_failures,
              PROMISE          => promise)
  end

  def request promise, env
    http = ::Net::HTTP::Persistent.new
    http.open_timeout, http.read_timeout = calculate_timeout(env[TIMER])

    payload, headers = Payload.generate_with_headers(env[REQUEST_PAYLOAD],
                                                     env[REQUEST_HEADERS])

    uri = ::URI.parse(request_uri(env))
    req = ::Net::HTTP.const_get(env[REQUEST_METHOD].to_s.capitalize).
            new(uri, headers)
    req.body_stream = payload
    res = http.request(uri, req)

    promise.fulfill(res.body, res.code.to_i, normalize_headers(res.to_hash))
  rescue Exception => e
    promise.reject(e)
  end
end
