
require 'rest-core/test'

describe RC::AuthBasic do
  should 'lighten' do
    RC::Builder.client do
      s = self.class # this is only for ruby 1.8!
      use s::ErrorDetectorHttp
      run s::Dry
    end.new.lighten.attributes.should.key?(:error_detector)
  end
end
