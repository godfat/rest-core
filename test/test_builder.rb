
require 'rest-core/test'

describe RC::Builder do
  would 'default client app is a kind of RestCore::Engine' do
    RC::Builder.client.new.app.should.kind_of? RC::Engine
  end

  would 'default        app is a kind of RestCore::Engine' do
    RC::Builder.new.to_app.should.kind_of? RC::Engine
  end

  would 'switch default_engine to RestCore::Dry a' do
    builder = Class.new(RC::Builder)
    builder.default_engine = RC::Dry
    builder.new.to_app.class.should.eq RC::Dry
  end

  would 'switch default_engine to RestCore::Dry b' do
    builder = RC::Builder.dup
    builder.default_engine = RC::Dry
    builder.client.new.app.class.should.eq RC::Dry
  end

  would 'accept middleware without a member' do
    RC::Builder.client{
      use Class.new.send(:include, RC::Middleware)
    }.members.should.eq []
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
