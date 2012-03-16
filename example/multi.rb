
require 'rest-core'
require 'eventmachine'
RestCore::EmHttpRequest # there might be a autoload bug?
                        # omitting this line would cause
                        # stack level too deep (SystemStackError)

YourClient = RestCore::Builder.client do
  s = self.class # this is only for ruby 1.8!
  use s::DefaultSite , 'https://api.github.com/users/'
  use s::JsonDecode  , true
  use s::CommonLogger, method(:puts)
  use s::Cache       , nil, 3600
  run s::Auto
end

client = YourClient.new
EM.run{
  Fiber.new{
    fiber = Fiber.current
    result = {}
    client.get('cardinalblue'){ |response|
      result[0] = response
      fiber.resume(result) if result.size == 2
    }
    client.get('cardinalblue'){ |response|
      result[1] = response
      fiber.resume(result) if result.size == 2
    }
    p Fiber.yield
    EM.stop
  }.resume
  puts "It's not blocking..."
}
