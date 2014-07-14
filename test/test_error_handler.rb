
require 'rest-core/test'

describe RC::ErrorHandler do
  client = RC::Builder.client do
    use RC::ErrorHandler
    run RC::Dry
  end

  exp = Class.new(Exception)

  describe 'there is an exception' do
    would 'raise an error with future' do
      lambda{
      client.new.get('/', {}, RC::FAIL => [exp.new('fail')])
      }.should.raise(exp)
    end

    would 'give an error with callback' do
      client.new.get('/', {}, RC::FAIL => [exp.new('fail')]){ |res|
        res.should.kind_of?(exp)
      }
    end
  end

  describe 'error_handler gives an exception' do
    would 'raise an error with future' do
      lambda{
      client.new(:error_handler => lambda{ |res| exp.new }).
        get('/', {}, RC::FAIL => [true])
      }.should.raise(exp)
    end

    would 'give an error with callback' do
      client.new(:error_handler => lambda{ |res| exp.new }).
        get('/', {}, RC::FAIL => [true]){ |res| res.should.kind_of?(exp) }
    end
  end

  would 'no exception but errors' do
    client.new(:error_handler => lambda{ |res| 1 }).
      request(RC::FAIL => [0], RC::RESPONSE_KEY => RC::FAIL).should.eq [0, 1]
  end
end
