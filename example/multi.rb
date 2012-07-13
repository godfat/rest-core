
require 'rest-core'
require 'eventmachine'
RestCore::EmHttpRequest # there might be a autoload bug?
                        # omitting this line would cause
                        # stack level too deep (SystemStackError)

YourClient = RestCore::Builder.client do
  s = RestCore
  use s::DefaultSite , 'https://api.github.com/users/'
  use s::JsonDecode  , true
  use s::CommonLogger, method(:puts)
  use s::Cache       , nil, 3600
  run s::Auto
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
