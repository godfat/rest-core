
RestCore::Mixi = RestCore::Builder.client(
  :data, :consumer_key, :consumer_secret, :redirect_uri) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'http://api.mixi-platform.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}

  use s::Oauth2Header  , nil

  use s::CommonLogger  , lambda{|obj|obj}

  use s::Cache         , nil, 3600 do
    use s::ErrorHandler  , lambda{ |env| p env }
    use s::ErrorDetectorHttp
    use s::JsonDecode    , true
    run s::Ask
  end

  use s::Defaults      , :data     => lambda{{}}

  run s::RestClient
end

module RestCore::Mixi::Client
  include RestCore

  def access_token
    data['access_token'] if data.kind_of?(Hash)
  end

  def authorize_url queries={}
    url('https://mixi.jp/connect_authorize.pl',
        {:client_id     => consumer_key,
         :response_type => 'code',
         :scope         => 'r_profile'}.merge(queries))
  end

  def authorize! code, payload={}, opts={}
    pl = {:client_id     => consumer_key   ,
          :client_secret => consumer_secret,
          :redirect_uri  => redirect_uri   ,
          :grant_type    => 'authorization_code',
          :code          => code}.merge(payload)

    self.data = post('https://secure.mixi-platform.com/2/token', pl, {}, opts)
  end
end

RestCore::Mixi.send(:include, RestCore::Mixi::Client)
