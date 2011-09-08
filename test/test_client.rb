
require 'rest-core/test'

describe RestCore::Simple do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'do simple request' do
    stub_request(:get, 'http://localhost/').to_return(:body => '[]')
    RestCore::Simple.new.get('http://localhost/').should.eq '[]'
  end
end
