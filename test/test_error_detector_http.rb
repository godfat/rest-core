
require 'rest-core/test'

describe RC::ErrorDetectorHttp do
  should 'lighten' do
    client = RC::Builder.client do
      s = self.class # this is only for ruby 1.8!
      use s::ErrorDetectorHttp
      run s::Dry
    end.new.lighten

    client.attributes.should.key?(:error_detector)
    client.error_detector.should.kind_of?(Proc)
  end
end
