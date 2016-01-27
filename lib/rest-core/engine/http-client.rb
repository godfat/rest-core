
require 'httpclient'
# httpclient would require something (cookie manager) while initialized,
# so we should try to force requiring them to avoid require deadlock!
HTTPClient.new

require 'rest-core/engine'

class RestCore::HttpClient < RestCore::Engine
  private
  def request env
    client = ::HTTPClient.new
    client.cookie_manager = nil
    client.follow_redirect_count = 0
    client.transparent_gzip_decompression = true
    config = config_engine(env) and config.call(client)
    payload, headers = payload_and_headers(env)

    if env[HIJACK]
      request_async(client, payload, headers, env)
    else
      request_sync(client, payload, headers, env)
    end
  end

  def request_sync client, payload, headers, env
    res = client.request(env[REQUEST_METHOD], env[REQUEST_URI], nil,
            payload, {'User-Agent' => 'Ruby'}.merge(headers))

    {RESPONSE_STATUS  => res.status,
     RESPONSE_HEADERS => normalize_headers(res.header.all),
     RESPONSE_BODY    => res.content}
  end

  def request_async client, payload, headers, env
    res = client.request_async(env[REQUEST_METHOD], env[REQUEST_URI], nil,
            payload, {'User-Agent' => 'Ruby'}.merge(headers)).pop

    {RESPONSE_STATUS  => res.status,
     RESPONSE_HEADERS => normalize_headers(res.header.all),
     RESPONSE_BODY    => '',
     RESPONSE_SOCKET  => res.content}
  end
end
