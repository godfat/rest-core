
require 'rest-core/middleware'
require 'rest-core/util/hmac'

require 'cgi'
require 'openssl'

class RestCore::Oauth1Header
  def self.members; [:consumer_key, :consumer_secret, :callback]; end
  include RestCore::Middleware
  def call env
    start_time = Time.now
    headers = {'Authorization' => oauth_header(env)}.
                merge(env[REQUEST_HEADERS] || {})

    event = Event::WithHeader.new(Time.now - start_time,
              "Authorization: #{headers['Authorization']}")

    app.call(log(env.merge(REQUEST_HEADERS => headers), event))
  end

  def oauth_header env
    header = attach_signature(env,
      'oauth_consumer_key'     => consumer_key(env),
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_timestamps'       => Time.now.to_i,
      'oauth_nonce'            => nonce,
      'oauth_version'          => '1.0',
      'oauth_callback'         => callback(env))

    "OAuth #{header.map{ |(k, v)| "#{k}=\"#{v}\"" }.join(', ')}"
  end

  def attach_signature env, oauth_params
    params = reject_blank(oauth_params)
    params.merge('oauth_signature' => CGI.escape(signature(env, params)))
  end

  def signature env, params
    [Hmac.sha1("#{consumer_secret(env)}&",
               base_string(env, params))].pack('m').tr("\n", '')
  end

  def base_string env, oauth_params
    method   = env[REQUEST_METHOD].to_s.upcase
    base_uri = env[REQUEST_PATH]
    params   = reject_blank(oauth_params.merge(env[REQUEST_QUERY] || {})).
      to_a.sort.map{ |(k, v)|
        "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join('&')

    "#{method}&#{CGI.escape(base_uri)}&#{CGI.escape(params)}"
  end

  def nonce
    [OpenSSL::Random.random_bytes(32)].pack('m').tr("+/=\n", '')
  end

  def reject_blank params
    params.reject{ |k, v| v.nil? || (v.respond_to?(:strip) &&
                                     v.respond_to?(:empty) &&
                                     v.strip.empty? == true) }
  end
end
