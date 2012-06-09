
require 'rest-core'
require 'eventmachine'

client = RestCore::Builder.client{
  use RC::DefaultSite, 'https://graph.facebook.com/'
  use RC::CommonLogger, method(:puts)
  use RC::JsonDecode, true
  run RC::EmHttpRequestThunk
}.new

EM.run{
  Fiber.new{
    z = client.get('http://localhost:8080/very-slow')
    a = client.get(4)
    b = client.get(5)
    c = client.get(6)
    p z
    EM.stop
  }.resume
}
