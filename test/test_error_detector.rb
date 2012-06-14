
require 'rest-core/test'

describe RC::ErrorDetector do
  should 'lighten' do
    client = RC::Builder.client do
      use RC::ErrorDetector
      run RC::Dry
    end.new.lighten

    client.attributes.should.key?(:error_detector)
  end
end
