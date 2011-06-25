
require 'rest-core/middleware'
require 'rest-core/util/hmac'

require 'uri'
require 'openssl'

class RestCore::Oauth1Header
  def self.members
    [:request_token_path, :access_token_path, :authorize_path,
     :consumer_key, :consumer_secret,
     :callback, :verifier, :oauth_token, :oauth_token_secret]
  end
  include RestCore::Middleware
  def call env
    start_time = Time.now
    headers = {'Authorization' => oauth_header(env)}.
                merge(env[REQUEST_HEADERS] || {})

    event = Event::WithHeader.new(Time.now - start_time,
              "Authorization: #{headers['Authorization']}")

    app.call(log(cache_key(env.merge(REQUEST_HEADERS => headers)), event))
  end

  def cache_key env
    env.merge('cache.key' =>
      "#{request_uri(env)}&#{oauth_token(env)}&#{oauth_token_secret(env)}")
  end

  def oauth_header env
    header = attach_signature(env,
      'oauth_consumer_key'     => consumer_key(env),
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_timestamp'        => Time.now.to_i.to_s,
      'oauth_nonce'            => nonce,
      'oauth_version'          => '1.0',
      'oauth_callback'         => callback(env),
      'oauth_verifier'         => verifier(env),
      'oauth_token'            => oauth_token(env))

    "OAuth #{header.map{ |(k, v)| "#{k}=\"#{v}\"" }.join(', ')}"
  end

  def attach_signature env, oauth_params
    params = reject_blank(oauth_params)
    params.merge('oauth_signature' => encode(signature(env, params)))
  end

  def signature env, params
    [Hmac.sha1("#{consumer_secret(env)}&#{oauth_token_secret(env)}",
               base_string(env, params))].pack('m').tr("\n", '')
  end

  def base_string env, oauth_params
    method   = env[REQUEST_METHOD].to_s.upcase
    base_uri = env[REQUEST_PATH]
    query    = reject_blank(env[REQUEST_QUERY]   || {})
    payload  = reject_blank(env[REQUEST_PAYLOAD] || {})
    params   = reject_blank(oauth_params.merge(query.merge(payload))).
      to_a.sort.map{ |(k, v)|
        "#{encode(k.to_s)}=#{encode(v.to_s)}"}.join('&')

    "#{method}&#{encode(base_uri)}&#{encode(params)}"
  end

  def nonce
    [OpenSSL::Random.random_bytes(32)].pack('m').tr("+/=\n", '')
  end

  def reject_blank params
    params.reject{ |k, v| v.nil? || v == false ||
                                    (v.respond_to?(:strip) &&
                                     v.respond_to?(:empty) &&
                                     v.strip.empty? == true) }
  end

  def encode string
    URI.encode(string, /[^a-zA-Z0-9\-\.\_\~]/)
  end
end
