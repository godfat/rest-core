
require 'rest-core'
require 'rest-core/util/hmac'

RestCore::Facebook = RestCore::Builder.client(
  :data, :app_id, :secret, :old_site) do

  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://graph.facebook.com/'
  use s::DefaultHeaders, {'Accept'          => 'application/json',
                          'Accept-Language' => 'en-us'}
  use s::Oauth2Query   , nil

  use s::CommonLogger  , lambda{|obj|obj}

  use s::Cache         , nil, 3600 do
    use s::ErrorHandler  , lambda{ |env|
                             raise ::RestCore::Facebook::Error.call(env) }
    use s::ErrorDetector , lambda{ |env|
      if env[s::RESPONSE_BODY].kind_of?(Hash)
        env[s::RESPONSE_BODY]['error'] ||
        env[s::RESPONSE_BODY]['error_code']
      end}

    use s::JsonDecode    , true
    run s::Ask
  end

  use s::Defaults      , :data     => lambda{{}},
                         :old_site => 'https://api.facebook.com/'

  run s::RestClient
end

class RestCore::Facebook::Error < RuntimeError
  include RestCore
  class AccessToken        < Facebook::Error; end
  class InvalidAccessToken < AccessToken     ; end
  class MissingAccessToken < AccessToken     ; end

  attr_reader :error, :url
  def initialize error, url=''
    @error, @url = error, url
    super("#{error.inspect} from #{url}")
  end

  def self.call env
    error, url = env[RESPONSE_BODY], Middleware.request_uri(env)
    return new(env[FAIL], url) unless error.kind_of?(Hash)
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

module RestCore::Facebook::Client
  include RestCore

  def access_token
    data['access_token'] || data['oauth_token'] if data.kind_of?(Hash)
  end

  def access_token=  token
    data['access_token'] = token if data.kind_of?(Hash)
  end

  def secret_access_token; "#{app_id}|#{secret}"           ; end
  def accept             ; headers['Accept']               ; end
  def accept=         val; headers['Accept']          = val; end
  def lang               ; headers['Accept-Language']      ; end
  def lang=           val; headers['Accept-Language'] = val; end

  def authorized?        ; !!access_token                  ; end

  def next_page hash, opts={}, &cb
    if hash['paging'].kind_of?(Hash) && hash['paging']['next']
      get(hash['paging']['next'], {}, opts, &cb)
    else
      yield(nil) if block_given?
    end
  end

  def prev_page hash, opts={}, &cb
    if hash['paging'].kind_of?(Hash) && hash['paging']['previous']
      get(hash['paging']['previous'], {}, opts, &cb)
    else
      yield(nil) if block_given?
    end
  end
  alias_method :previous_page, :prev_page

  def for_pages hash, pages=1, opts={}, kind=:next_page, &cb
    if pages > 1
      merge_data(send(kind, hash, opts){ |result|
        yield(result.freeze) if block_given?
        for_pages(result, pages - 1, opts, kind, &cb) if result
      }, hash)
    else
      yield(nil) if block_given?
      hash
    end
  end

  # cookies, app_id, secrect related below

  def parse_rack_env! env
    env['HTTP_COOKIE'].to_s =~ /fbs_#{app_id}=([^\;]+)/
    self.data = parse_fbs!($1)
  end

  def parse_cookies! cookies
    self.data = parse_fbs!(cookies["fbs_#{app_id}"])
  end

  def parse_fbs! fbs
    self.data = check_sig_and_return_data(
      # take out facebook sometimes there but sometimes not quotes in cookies
      Vendor.parse_query(fbs.to_s.sub(/^"/, '').sub(/"$/, '')))
  end

  def parse_json! json
    self.data = json &&
      check_sig_and_return_data(JsonDecode.json_decode(json))
  rescue JsonDecode::ParseError
    self.data = nil
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
                    Hmac.sha256(secret, json_encoded)
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
    self.data = Vendor.parse_query(
                  get(url('oauth/access_token'), query,
                      {:json_decode => false}.merge(opts)))
  end

  # old rest facebook api, i will definitely love to remove them someday

  def old_rest path, query={}, opts={}, &cb
    uri = url("method/#{path}", {:format => 'json'}.merge(query),
              {:site => old_site}.merge(opts))
    if opts[:post]
      post(url("method/#{path}", {:format => 'json'},
               {:site => old_site}.merge(opts)),
           query,
           {}   ,
           opts.merge('cache.key' => uri, 'cache.post' => true),
           &cb)
    else
      get(uri, {}, opts, &cb)
    end
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

  def exchange_sessions query={}, opts={}, &cb
    q = {:client_id => app_id, :client_secret => secret,
         :type => 'client_cred'}.merge(query)
    post(url('oauth/exchange_sessions', q),
         {}, {}, opts, &cb)
  end

  protected
  def build_env env={}
    super(env.inject({}){ |r, (k, v)|
      case k.to_s
        when 'secret'     ; r['access_token'] = secret_access_token
        when 'cache'      ; r['cache.update'] = !!!v
        else              ; r[k.to_s]         = v
      end
      r
    })
  end

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

  def merge_data lhs, rhs
    [lhs, rhs].each{ |hash|
      return rhs.reject{ |k, v| k == 'paging' } if
        !hash.kind_of?(Hash) || !hash['data'].kind_of?(Array)
    }
    lhs['data'].unshift(*rhs['data'])
    lhs
  end
end

RestCore::Facebook.send(:include, RestCore::Facebook::Client)
require 'rest-core/client/facebook/rails_util' if
  Object.const_defined?(:Rails)
