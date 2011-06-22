
RestCore::Builder.client('Github', :api_key,
                                   :consumer_key,
                                   :consumer_secret, :old_site) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.github.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}
  use s::Oauth2Query   , 'access_token', nil

  use s::CommonLogger  , lambda{|obj|obj}
  use s::Cache         , {}, nil do
    use s::ErrorHandler  , lambda{ |env| raise env.inspect }
    use s::ErrorDetector , lambda{ |env| env[s::RESPONSE_HEADERS]['status'].
                                         first !~ /^2/ }
    use s::JsonDecode    , true
    run s::Ask
  end

  run s::RestClient
end
