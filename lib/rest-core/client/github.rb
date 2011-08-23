
require 'rest-core'

RestCore::Github = RestCore::Builder.client do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.github.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}
  use s::Oauth2Query   , 'access_token', nil

  use s::CommonLogger  , lambda{|obj|obj}
  use s::Cache         , {}, 3600 do
    use s::ErrorHandler , lambda{|env| raise env[s::RESPONSE_BODY]['message']}
    use s::ErrorDetectorHttp
    use s::JsonDecode   , true
    run s::Ask
  end

  run s::RestClient
end
