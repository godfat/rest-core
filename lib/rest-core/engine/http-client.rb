
require 'httpclient'
require 'rest-core/engine'

class RestCore::HttpClient < RestCore::Engine
  def request promise, env
    client = ::HTTPClient.new
    client.cookie_manager = nil
    client.follow_redirect_count = 0
    client.transparent_gzip_decompression = true
    client.connect_timeout, client.receive_timeout =
      calculate_timeout(env[TIMER])
    payload, headers = payload_and_headers(env)

    res = client.request(env[REQUEST_METHOD], request_uri(env), nil,
                         payload, {'User-Agent' => 'Ruby'}.merge(headers))

    promise.fulfill(res.content, res.status,
                    normalize_headers(res.header.all))
  rescue Exception => e
    promise.reject(e)
  end
end
