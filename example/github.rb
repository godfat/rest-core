
# simple client

require 'rest-core'

RestCore::Builder.client('Github') do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout      , 10

  use s::DefaultSite  , 'https://api.github.com/'
  use s::Oauth2Query  , 'access_token', nil

  use s::CommonLogger , method(:puts)
  use s::Cache        , {}, nil
  use s::ErrorHandler , lambda{|env| raise env[s::RESPONSE_BODY]['message']}
  use s::ErrorDetector, lambda{|env| env[s::RESPONSE_HEADERS]['status'].
                                     first !~ /^2/}
  use s::JsonDecode   , true

  run s::RestClient
end
