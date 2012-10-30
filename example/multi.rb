
require 'fiber'
require 'em-http-request'
require 'rest-core'

YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonResponse, true
  use RC::CommonLogger, method(:puts)
  use RC::Cache       , nil, 3600
end

client = YourClient.new
puts "rest-client with threads doing concurrent requests"
a = [client.get('cardinalblue')['name'], client.get('godfat')['name']]
puts "It's not blocking... but doing concurrent requests underneath"
p a # here we want the values, so it blocks here
puts "DONE"

puts; puts

puts "eventmachine with threads doing concurrent requests"
EM.run{
  Thread.new{
    p [client.get('cardinalblue')['name'], client.get('godfat')['name']]
    puts "DONE"
    EM.stop
  }
  puts "It's not blocking... but doing concurrent requests underneath"
}

puts; puts

puts "eventmachine with fibers doing concurrent requests"
EM.run{
  Fiber.new{
    p [client.get('cardinalblue')['name'], client.get('godfat')['name']]
    puts "DONE"
    EM.stop
  }.resume
  puts "It's not blocking... but doing concurrent requests underneath"
}
