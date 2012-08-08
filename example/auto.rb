
require 'rest-core'
require 'eventmachine'

YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonResponse, true
  use RC::CommonLogger, method(:puts)
  use RC::Cache       , nil, 3600
end

client = YourClient.new(:cache => {})
p client.get('cardinalblue') # cache miss
puts
p client.get('cardinalblue') # cache hit

puts

client = YourClient.new(:cache => {})
EM.run{
  client.get('cardinalblue'){ |response|
    p response
    EM.stop
  }
}

puts

EM.run{
  Fiber.new{
    p client.get('cardinalblue')
    EM.stop
  }.resume
}
