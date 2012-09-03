
require 'rest-core/test'

describe RC::Builder do
  should 'default app is RestCore::Auto' do
    RC::Builder.client.new.app.class.should.eq RC::Auto
  end

  should 'switch default_engine to RestCore::Dry' do
    builder = RC::Builder.dup
    builder.default_engine = RC::Dry
    builder.client.new.app.class.should.eq RC::Dry
  end
end
