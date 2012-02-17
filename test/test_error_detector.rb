
require 'rest-core/test'

describe RC::ErrorDetector do
  should 'lighten' do
    client = RC::Builder.client do
      s = self.class # this is only for ruby 1.8!
      use s::ErrorDetector
      run s::Dry
    end.new.lighten

    client.attributes.should.key?(:error_detector)
    client.app.call({}).should.eq({})
  end
end
