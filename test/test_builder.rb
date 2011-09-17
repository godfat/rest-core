
require 'rest-core/test'

describe RestCore::Builder do
  should 'default app is RestCore::RestClient' do
    RestCore::Builder.client.new.app.class.should.eq RestCore::RestClient
  end

  should 'switch default_app to RestCore::Dry' do
    builder = RestCore::Builder.dup
    builder.default_app = RestCore::Dry
    builder.client.new.app.class.should.eq RestCore::Dry
  end
end
