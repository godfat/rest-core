
require 'rest-core/test'

describe RC::EmHttpRequest do
  should 'raise RC::Error' do
    EM.run{Fiber.new{
      lambda{
        RC::Universal.new.get('http://localhost:1').tap{}
      }.should.raise(RC::Error)
      EM.stop
    }.resume}
  end
end
