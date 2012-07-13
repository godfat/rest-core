
require 'rest-core'
require 'eventmachine'

client = RestCore::Builder.client{
  use RC::DefaultSite, 'https://graph.facebook.com/'
  use RC::CommonLogger, method(:puts)
  use RC::JsonDecode, true
  run RC::EmHttpRequest
}.new

EM.run{
  Fiber.new{
    z = client.get('http://localhost:4331/very-slow')
    a = client.get(4)
    b = client.get(5)
    c = client.get(6){ |q| p q }
    p b
    EM.stop
  }.resume
}
