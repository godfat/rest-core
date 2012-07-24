
require 'rest-core'
require 'eventmachine'

YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonDecode  , true
  use RC::CommonLogger, method(:puts)
  use RC::Cache       , nil, 3600
end

client = YourClient.new
EM.run{
  Fiber.new{
    p [client.get('cardinalblue'), client.get('godfat')]
    puts "But blocks here and do concurrent requests..."
    EM.stop
  }.resume
  puts "It's not blocking..."
}
