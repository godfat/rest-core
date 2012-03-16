
require 'rest-core'

YourClient = RestCore::Builder.client do
  s = self.class # this is only for ruby 1.8!
  use s::DefaultSite , 'https://api.github.com/users/'
  use s::JsonDecode  , true
  use s::CommonLogger, method(:puts)
  use s::Cache       , {}, 3600
  run s::RestClient
end

client = YourClient.new
p client.get('cardinalblue') # cache miss
puts
p client.get('cardinalblue') # cache hit
