
require 'rest-core'
require 'eventmachine'

YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonResponse, true
  use RC::CommonLogger, method(:puts)
  use RC::Cache       , nil, 3600
end

client = YourClient.new
EM.run{
  Fiber.new{
    p [client.get('cardinalblue')['name'], client.get('godfat')['name']]
    puts "But blocks here and do concurrent requests..."
    EM.stop
  }.resume
  puts "It's not blocking..."
}

puts; puts

EM.run{
  Thread.new{
    p [client.get('cardinalblue')['name'], client.get('godfat')['name']]
    puts "But blocks here and do concurrent requests..."
    EM.stop
  }
  puts "Thread also works..."
}

puts; puts

puts "Without EventMachine also works..."
p [client.get('cardinalblue')['name'], client.get('godfat')['name']]
puts "But blocks here and do concurrent requests..."
