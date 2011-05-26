
# optional http client
begin; require 'restclient'     ; rescue LoadError; end
begin; require 'em-http-request'; rescue LoadError; end

# optional gem
begin; require 'rack'           ; rescue LoadError; end

# stdlib
require 'openssl'

require 'cgi'

RestCore::Builder.client('RestGraph',
                         :app_id, :secret,
                         :old_site,
                         :old_server, :graph_server) do

  use DefaultSite   ,  'https://graph.facebook.com/'
  use ErrorDetector , lambda{ |env| env[RESPONSE_BODY]['error'] ||
                                    env[RESPONSE_BODY]['error_code'] }
  use AutoJsonDecode, true

  use Cache         , {}
  use Timeout       ,  10
  use DefaultHeaders, {'Accept'          => 'application/json',
                       'Accept-Language' => 'en-us'}

  use ErrorHandler  , lambda{ |env| raise ::RestGraph::Error.call(env) }
  use CommonLogger  , method(:puts)

  run RestClient
end

class RestGraph::Error < RuntimeError
  include RestCore
  class AccessToken        < RestGraph::Error; end
  class InvalidAccessToken < AccessToken     ; end
  class MissingAccessToken < AccessToken     ; end

  attr_reader :error, :url
  def initialize error, url=''
    @error, @url = error, url
    super("#{error.inspect} from #{url}")
  end

  def self.call env
    error, url = env[RESPONSE_BODY], env[REQUEST_URI]
    return new(error, url) unless error.kind_of?(Hash)
    if    invalid_token?(error)
      InvalidAccessToken.new(error, url)
    elsif missing_token?(error)
      MissingAccessToken.new(error, url)
    else
      new(error, url)
    end
  end

  def self.invalid_token? error
    (%w[OAuthInvalidTokenException
        OAuthException].include?((error['error'] || {})['type'])) ||
    (error['error_code'] == 190) # Invalid OAuth 2.0 Access Token
  end

  def self.missing_token? error
    (error['error'] || {})['message'] =~ /^An active access token/ ||
    (error['error_code'] == 104) # Requires valid signature
  end
end

#   module Hmac
#     # Fallback to ruby-hmac gem in case system openssl
#     # lib doesn't support SHA256 (OSX 10.5)
#     def hmac_sha256 key, data
#       OpenSSL::HMAC.digest('sha256', key, data)
#     rescue RuntimeError
#       require 'hmac-sha2'
#       HMAC::SHA256.digest(key, data)
#     end
#   end
