
require 'rest-core/test'

describe RC::ErrorDetectorHttp do
  should 'lighten' do
    client = RC::Builder.client do
      use RC::ErrorDetectorHttp
      run RC::Dry
    end.new.lighten

    client.attributes.should.key?(:error_detector)
    client.error_detector.should.kind_of?(Proc)
  end
end
