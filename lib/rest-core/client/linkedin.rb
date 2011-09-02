
require 'rest-core'

RestCore::Linkedin = RestCore::Builder.client(:data) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.linkedin.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}
  use s::DefaultQuery  , {'format' => 'json'}

  use s::Oauth1Header  ,
    'uas/oauth/requestToken', 'uas/oauth/accessToken',
    'https://www.linkedin.com/uas/oauth/authorize'

  use s::CommonLogger  , method(:puts)

  use s::Cache         , nil, 3600 do
    use s::ErrorHandler , lambda{|env|
      if (body = env[s::RESPONSE_BODY]).kind_of?(Hash)
        raise body['message']
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

module RestCore::Linkedin::Client
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

  def me queries={}, opts={}
    get('v1/people/~', queries, opts)
  end

  private
  def set_token query
    self.data = query
  end
end

RestCore::Linkedin.send(:include, RestCore::ClientOauth1)
RestCore::Linkedin.send(:include, RestCore::Linkedin::Client)
