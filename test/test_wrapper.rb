
require 'rest-core/test'

describe RestCore::Wrapper do
  should 'wrap around simple middleware' do
    mid = RestCore::Bypass.dup
    mid.send(:include, RestCore::Wrapper)
    client = RestCore::Builder.client do
      use mid do
        use RestCore::Bypass
      end
      run RestCore::Ask
    end

    client.new.app.call({1=>2}).should.eq({1=>2})
  end
end
