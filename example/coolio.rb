
require 'rest-core'

AsynchronousClient = RestCore::Builder.client do
  s = self.class # this is only for ruby 1.8!
  use s::DefaultSite , 'https://api.github.com/users/'
  use s::JsonDecode  , true
  use s::CommonLogger, method(:puts)
  use s::Cache       , nil, 3600
  run s::Coolio
end

AsynchronousClient.new.get('cardinalblue'){ |response|
  p response
}
Coolio::Loop.default.run

puts

Fiber.new{ p AsynchronousClient.new.get('cardinalblue') }.resume
Coolio::Loop.default.run
