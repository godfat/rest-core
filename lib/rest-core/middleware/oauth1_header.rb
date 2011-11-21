
require 'rest-core/middleware'
require 'rest-core/util/hmac'

require 'cgi'
require 'openssl'

class RestCore::Oauth1Header
  def self.members
    [:request_token_path, :access_token_path, :authorize_path,
     :consumer_key, :consumer_secret,
     :oauth_callback, :oauth_verifier,
     :oauth_token, :oauth_token_secret, :data]
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
      'oauth_callback'         => oauth_callback(env),
      'oauth_verifier'         => oauth_verifier(env),
      'oauth_token'            => oauth_token(env))

    "OAuth #{header.map{ |(k, v)| "#{k}=\"#{v}\"" }.join(', ')}"
  end

  def attach_signature env, oauth_params
    params = reject_blank(oauth_params)
    params.merge('oauth_signature' => escape(signature(env, params)))
  end

  def signature env, params
    [Hmac.sha1("#{consumer_secret(env)}&#{oauth_token_secret(env)}",
               base_string(env, params))].pack('m').tr("\n", '')
  end

  def base_string env, oauth_params
    method   = env[REQUEST_METHOD].to_s.upcase
    base_uri = env[REQUEST_PATH]
    # TODO: the detection should be checking if it's
    # application/x-www-form-urlencoded or not, instead of multipart or not.
    # but since the Content-Type is generated in app (http client),
    # we have no idea what it would be here. so simply guessing it...
    payload  = if multipart?(env)
                 {}
               else
                 reject_blank(env[REQUEST_PAYLOAD] || {})
               end
    query    = reject_blank(env[REQUEST_QUERY] || {})
    params   = reject_blank(oauth_params.merge(query.merge(payload))).
      to_a.sort.map{ |(k, v)|
        "#{escape(k.to_s)}=#{escape(v.to_s)}"}.join('&')

    "#{method}&#{escape(base_uri)}&#{escape(params)}"
  end

  def nonce
    [OpenSSL::Random.random_bytes(32)].pack('m').tr("+/=\n", '')
  end

  def multipart? env
    !!(env[REQUEST_PAYLOAD] &&
       env[REQUEST_PAYLOAD].find{ |k, v| v.kind_of?(IO) ||
                                         v.respond_to?(:read) })
  end

  def reject_blank params
    params.reject{ |k, v| v.nil? || v == false ||
                                    (v.respond_to?(:strip) &&
                                     v.respond_to?(:empty) &&
                                     v.strip.empty? == true) }
  end

  def escape string
    CGI.escape(string).gsub('+', '%20')
  end
end
