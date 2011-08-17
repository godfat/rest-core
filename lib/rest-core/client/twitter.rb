
require 'rest-core'

RestCore::Twitter = RestCore::Builder.client(:data) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.twitter.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}

  use s::Oauth1Header  ,
    'oauth/request_token', 'oauth/access_token', 'oauth/authorize'

  use s::CommonLogger  , method(:puts)

  use s::Cache         , {}, nil do
    use s::ErrorHandler  , lambda{ |env|
      if (body = env[s::RESPONSE_BODY]).kind_of?(Hash)
        raise body['error']
      else
        raise body
      end
    }
    use s::ErrorDetectorHttp
    use s::JsonDecode    , true
    run s::Ask
  end

  use s::Defaults      , :data     => lambda{{}}

  run s::RestClient
end

module Twitter::Client
  include RestCore

  def oauth_token
    data['oauth_token'] if data.kind_of?(Hash)
  end
  def oauth_token=  token
    data['oauth_token'] = token if data.kind_of?(Hash)
  end
  def oauth_token_secret
    data['oauth_token_secret'] if data.kind_of?(Hash)
  end
  def oauth_token_secret=  secret
    data['oauth_token_secret'] = secret if data.kind_of?(Hash)
  end

  def tweet status, opt={}
    post('1/statuses/update.json', {:status => status}.merge(opt))
  end

  private
  def set_token query
    self.data = query
  end
end

RestCore::Twitter.send(:include, RestCore::ClientOauth1)
RestCore::Twitter.send(:include,  Twitter::Client)
