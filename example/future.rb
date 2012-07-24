
require 'rest-core'
require 'eventmachine'

client = RC::Builder.client{
  use RC::DefaultSite, 'https://graph.facebook.com/'
  use RC::CommonLogger, method(:puts)
  use RC::JsonDecode, true
}.new

EM.run{
  Fiber.new{
    r = []
    z = client.get('http://localhost:8080/very-slow') # not dependant
    a = client.get(4)                                 # not dependant
    b = client.get(5)
    c = client.get(6){ |q| r << p(q); EM.stop if r.size == 2 } # non-blocking
    r << p(b) # here it blocks because b is needed
    EM.stop if r.size == 2
  }.resume
}
