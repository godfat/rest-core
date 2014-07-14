
require 'rest-core/test'

describe RC::Builder do
  would 'default app is a kind of RestCore::Dry' do
    RC::Builder.client.new.app.should.kind_of? RC::Engine
  end

  would 'switch default_engine to RestCore::Dry' do
    builder = RC::Builder.dup
    builder.default_engine = RC::Dry
    builder.client.new.app.class.should.eq RC::Dry
  end

  would 'not have duplicated fields' do
    middleware = Class.new do
      def self.members; [:value]; end
      include RC::Middleware
    end
    client = RC::Builder.client(:value){ use middleware }.new
    client.value = 10
    client.value.should.eq 10
  end
end
