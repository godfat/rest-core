
require 'httpclient'
require 'rest-core/engine'

class RestCore::HttpClient < RestCore::Engine
  private
  def request promise, env
    client = ::HTTPClient.new
    client.cookie_manager = nil
    client.follow_redirect_count = 0
    client.transparent_gzip_decompression = true
    payload, headers = payload_and_headers(env)

    if env[HIJACK]
      request_async(client, payload, headers, promise, env)
    else
      request_sync(client, payload, headers, promise, env)
    end
  rescue Exception => e
    promise.reject(e)
  end

  def request_sync client, payload, headers, promise, env
    client.connect_timeout, client.receive_timeout =
      calculate_timeout(env[TIMER])

    res = client.request(env[REQUEST_METHOD], env[REQUEST_URI], nil,
            payload, {'User-Agent' => 'Ruby'}.merge(headers))

    promise.fulfill(res.content, res.status,
                    normalize_headers(res.header.all))
  end

  def request_async client, payload, headers, promise, env
    res = client.request_async(env[REQUEST_METHOD], env[REQUEST_URI], nil,
            payload, {'User-Agent' => 'Ruby'}.merge(headers)).pop

    promise.fulfill('', res.status,
                    normalize_headers(res.header.all), res.content)
  end
end
