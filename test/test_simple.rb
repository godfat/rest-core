
require 'rest-core/test'

describe RC::Simple do
  path = 'http://example.com/'

  after do
    WebMock.reset!
  end

  should 'give RESPONSE_BODY' do
    stub_request(:get, path).to_return(:body => 'OK')
    RC::Simple.new.get(path).should.eq 'OK'
  end

  should 'give RESPONSE_HEADERS' do
    stub_request(:head, path).to_return(:headers => {'A' => 'B'})
    RC::Simple.new.head(path).should.eq 'A' => 'B'
  end

  should 'give RESPONSE_HEADERS' do
    stub_request(:get, path).to_return(:status => 199)
    RC::Simple.new.get(path, {},
      RC::RESPONSE_KEY => RC::RESPONSE_STATUS).should.eq 199
  end

  should 'give RESPONSE_SOCKET' do
    stub_request(:get, path).to_return(:body => 'OK')
    RC::Simple.new.get(path, {}, RC::HIJACK => true).read.should.eq 'OK'
  end

  should 'give REQUEST_URI' do
    stub_request(:get, "#{path}?a=b").to_return(:body => 'OK')
    RC::Simple.new.get(path, {:a => 'b'},
      RC::RESPONSE_KEY => RC::REQUEST_URI).should.eq "#{path}?a=b"
  end
end
