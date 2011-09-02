
require 'rest-core'

RestCore::Twitter = RestCore::Builder.client(:data) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.twitter.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}

  use s::Oauth1Header  ,
    'oauth/request_token', 'oauth/access_token', 'oauth/authorize'

  use s::CommonLogger  , method(:puts)

  use s::Cache         , nil, 3600 do
    use s::ErrorHandler  , lambda{ |env|
                             raise ::RestCore::Twitter::Error.call(env) }
    use s::ErrorDetectorHttp
    use s::JsonDecode    , true
    run s::Ask
  end

  use s::Defaults      , :data     => lambda{{}}

  run s::RestClient
end

class RestCore::Twitter::Error < RuntimeError
  include RestCore
  class ServerError         < Twitter::Error; end

  class BadRequest          < Twitter::Error; end
  class Unauthorized        < Twitter::Error; end
  class Forbidden           < Twitter::Error; end
  class NotFound            < Twitter::Error; end
  class NotAcceptable       < Twitter::Error; end
  class EnhanceYourCalm     < Twitter::Error; end

  class InternalServerError < Twitter::Error::ServerError; end
  class BadGateway          < Twitter::Error::ServerError; end
  class ServiceUnavailable  < Twitter::Error::ServerError; end

  attr_reader :error, :url
  def initialize error, url=''
    @error, @url = error, url
    super("#{error.inspect} from #{url}")
  end

  def self.call env
    error, url = env[RESPONSE_BODY], Middleware.request_uri(env)
    return new(env[FAIL], url) unless error.kind_of?(Hash)
    case env[RESPONSE_STATUS]
      when 400; BadRequest
      when 401; Unauthorized
      when 403; Forbidden
      when 404; NotFound
      when 406; NotAcceptable
      when 420; EnhanceYourCalm
      when 500; InternalServerError
      when 502; BadGateway
      when 503; ServiceUnavailable
      else    ; self
    end.new(error, url)
  end
end

module RestCore::Twitter::Client
  include RestCore

  def oauth_token
    data['oauth_token'] if data.kind_of?(Hash)
  end
  def oauth_token= token
    data['oauth_token'] = token if data.kind_of?(Hash)
  end
  def oauth_token_secret
    data['oauth_token_secret'] if data.kind_of?(Hash)
  end
  def oauth_token_secret= secret
    data['oauth_token_secret'] = secret if data.kind_of?(Hash)
  end

  def tweet status, media=nil, opts={}
    if media
      post('https://upload.twitter.com/1/statuses/update_with_media.json',
        {:status => status, 'media[]' => media},
        {}, opts)
    else
      post('1/statuses/update.json', {:status => status}, {}, opts)
    end
  end

  def statuses user, queries={}, opts={}
    get('1/statuses/user_timeline.json', {:id => user}.merge(queries), opts)
  end

  private
  def set_token query
    self.data = query
  end
end

RestCore::Twitter.send(:include, RestCore::ClientOauth1)
RestCore::Twitter.send(:include, RestCore::Twitter::Client)
