
# simple client

require 'rest-core'

RestCore::Builder.client('Facebook', :data, :app_id, :secret, :old_site) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://graph.facebook.com/'
  use s::DefaultHeaders, {'Accept'          => 'application/json',
                          'Accept-Language' => 'en-us'}
  use s::Oauth2Query   , 'access_token', nil

  use s::CommonLogger  , method(:puts)
  use s::Cache         , {}, nil
  use s::ErrorHandler  , lambda{ |env| raise ::Facebook::Error.call(env) }
  use s::ErrorDetector , lambda{ |env| env[s::RESPONSE_BODY]['error'] ||
                                       env[s::RESPONSE_BODY]['error_code'] }
  use s::JsonDecode    , true

  use s::Defaults      , :data     => lambda{{}},
                         :old_site => 'https://api.facebook.com/'

  run s::RestClient
end

class Facebook::Error < RuntimeError
  include RestCore

  attr_reader :error, :url
  def initialize error, url=''
    @error, @url = error, url
    super("#{error.inspect} from #{url}")
  end

  def self.call env
    error, url = env[RESPONSE_BODY], Middleware.request_uri(env)
    new(error, url)
  end
end

module Facebook::Client
  include RestCore

  def oauth_token
    data['access_token'] || data['oauth_token'] if data.kind_of?(Hash)
  end
  def oauth_token=  token
    data['access_token'] = token if data.kind_of?(Hash)
  end
  alias_method :access_token , :oauth_token
  alias_method :access_token=, :oauth_token=

  def secret_oauth_token ; "#{app_id}|#{secret}"           ; end
  alias_method :secret_access_token, :secret_oauth_token

  def accept             ; headers['Accept']               ; end
  def accept=         val; headers['Accept']          = val; end
  def lang               ; headers['Accept-Language']      ; end
  def lang=           val; headers['Accept-Language'] = val; end

  def authorized?        ; !!oauth_token                   ; end

  # cookies, app_id, secrect related below

  def parse_fbs! fbs
    self.data = check_sig_and_return_data(
      # take out facebook sometimes there but sometimes not quotes in cookies
      Rack::Utils.parse_query(fbs.to_s.sub(/^"/, '').sub(/"$/, '')))
  end

  def fbs
    "#{fbs_without_sig(data).join('&')}&sig=#{calculate_sig(data)}"
  end

  # facebook's new signed_request...

  def parse_signed_request! request
    sig_encoded, json_encoded = request.split('.')
    sig,  json = [sig_encoded, json_encoded].map{ |str|
      "#{str.tr('-_', '+/')}==".unpack('m').first
    }
    self.data = check_sig_and_return_data(
                  JsonDecode.json_decode(json).merge('sig' => sig)){
                    self.class.hmac_sha256(secret, json_encoded)
                  }
  rescue JsonDecode::ParseError
    self.data = nil
  end

  # oauth related

  def authorize_url opts={}
    url('oauth/authorize',
        {:client_id => app_id, :access_token => nil}.merge(opts))
  end

  def authorize! opts={}
    query = {:client_id => app_id, :client_secret => secret}.merge(opts)
    self.data = Rack::Utils.parse_query(
                  request({:auto_decode => false}.merge(opts),
                          [:get, url('oauth/access_token', query)]))
  end

  # old rest facebook api, i will definitely love to remove them someday

  def old_rest path, query={}, opts={}, &cb
    uri = url("method/#{path}", {:format => 'json'}.merge(query),
              {:site => old_site}.merge(opts))
    request(opts, [:get, uri], &cb)
  end

  def secret_old_rest path, query={}, opts={}, &cb
    old_rest(path, query, {:secret => true}.merge(opts), &cb)
  end

  def fql code, query={}, opts={}, &cb
    old_rest('fql.query', {:query => code}.merge(query), opts, &cb)
  end

  def fql_multi codes, query={}, opts={}, &cb
    old_rest('fql.multiquery',
      {:queries => JsonDecode.json_encode(codes)}.merge(query), opts, &cb)
  end

  protected
  def check_sig_and_return_data cookies
    cookies if secret && if block_given?
                           yield
                         else
                           calculate_sig(cookies)
                         end == cookies['sig']
  end

  def calculate_sig cookies
    Digest::MD5.hexdigest(fbs_without_sig(cookies).join + secret)
  end

  def fbs_without_sig cookies
    cookies.reject{ |(k, v)| k == 'sig' }.sort.map{ |a| a.join('=') }
  end
end

module Facebook::Hmac
  # Fallback to ruby-hmac gem in case system openssl
  # lib doesn't support SHA256 (OSX 10.5)
  def hmac_sha256 key, data
    OpenSSL::HMAC.digest('sha256', key, data)
  rescue RuntimeError
    require 'hmac-sha2'
    HMAC::SHA256.digest(key, data)
  end
end

Facebook.send(:include, Facebook::Client)
Facebook.send(:extend , Facebook::Hmac)
