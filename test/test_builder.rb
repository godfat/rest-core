
require 'rest-core/test'

describe RestCore::Builder do
  should 'default app is RestCore::RestClient' do
    RestCore::Builder.client.new.app.class.should.eq RestCore::RestClient
  end
end
