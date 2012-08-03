
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

  should 'never crash EM!' do
    EM.error_handler{ |e| e.should.kind_of?(NoMethodError); EM.stop}
    EM.run{Fiber.new{
      RC::Simple.new.get('http://localhost:1').no_such_method
    }.resume}
  end
end
