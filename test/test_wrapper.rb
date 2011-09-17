
require 'rest-core/test'

describe RestCore::Wrapper do
  should 'wrap around simple middleware' do
    wrapper = RestCore::Bypass.dup
    wrapper.send(:include, RestCore::Wrapper)
    client = RestCore::Builder.client do
      use wrapper do
        use RestCore::Bypass
      end
      run RestCore::Dry
    end

    client.new.app.call({1=>2}).should.eq({1=>2})
  end

  should 'default app is RestCore::Dry' do
    wrapper = Class.new
    wrapper.send(:include, RestCore::Wrapper)
    wrapper.new.wrapped.class.should.eq RestCore::Dry
  end

  should 'switch default_app to RestCore::RestClient' do
    wrapper = Class.new
    wrapper.send(:include, RestCore::Wrapper)
    wrapper.default_app = RestCore::RestClient
    wrapper.new.wrapped.class.should.eq RestCore::RestClient
  end
end
