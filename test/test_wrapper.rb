
require 'rest-core/test'

describe RestCore::Wrapper do
  should 'wrap around simple middleware' do
    wrapper = RestCore::Bypass.dup
    wrapper.send(:include, RestCore::Wrapper)
    client = RestCore::Builder.client do
      use wrapper do
        use RestCore::Bypass
      end
      run RestCore::Ask
    end

    client.new.app.call({1=>2}).should.eq({1=>2})
  end

  should 'raise RestCore::Error if no app specified' do
    lambda{
      RestCore::Builder.client.new
    }.should.raise(RestCore::Error)
  end
end
