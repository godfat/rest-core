
require 'rest-core'
require 'eventmachine'
require 'cool.io'

YourClient = RestCore::Builder.client do
  s = self.class # this is only for ruby 1.8!
  use s::DefaultSite , 'https://api.github.com/users/'
  use s::JsonDecode  , true
  use s::CommonLogger, method(:puts)
  use s::Cache       , nil, 3600
  run s::Auto
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

puts

client = YourClient.new(:cache => {})
Coolio::TimerWatcher.new(1).attach(Coolio::Loop.default).on_timer{detach}
client.get('cardinalblue'){ |response|
  p response
}
Coolio::Loop.default.run

puts
Coolio::TimerWatcher.new(1).attach(Coolio::Loop.default).on_timer{detach}
Fiber.new{ p client.get('cardinalblue') }.resume
Coolio::Loop.default.run
