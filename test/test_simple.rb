
require 'rest-core/test'

describe RC::Simple do
  before do
    @path = 'http://example.com'
    stub_request(:get, @path).to_return(:body => 'OK')
  end

  should 'work with RC' do
    RC::Simple.new.get(@path).should.eq 'OK'
  end
end

