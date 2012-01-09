
require 'rest-core/test'

describe RC::JsonDecode do
  before do
    @app = RC::JsonDecode.new(RC::Dry.new, true)
  end

  should 'do nothing' do
    @app.call({}).should.eq(RC::RESPONSE_BODY => nil)
  end

  should 'decode sync' do
    @app.call(RC::RESPONSE_BODY => '{}').should.eq(
              RC::RESPONSE_BODY =>  {} )
  end

  should 'decode async' do
    @app.call(RC::RESPONSE_BODY => '{}',
              RC::ASYNC => lambda{ |response|
                             response[RC::RESPONSE_BODY].should.eq({})})
  end
end
