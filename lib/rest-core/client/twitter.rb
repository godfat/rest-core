
RestCore::Builder.client('Twitter', :data) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.twitter.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}
  use s::Oauth1Header  ,
    'oauth/request_token', 'oauth/access_token', 'oauth/authorize'

  use s::CommonLogger  , method(:puts)

  use s::Cache         , {}, nil do
    use s::ErrorHandler  , lambda{|env| raise env[s::RESPONSE_BODY]['error'] }
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

  private
  def set_token query
    self.data = query
  end
end

Twitter.send(:include, RestCore::ClientOauth1)
Twitter.send(:include,  Twitter::Client)
