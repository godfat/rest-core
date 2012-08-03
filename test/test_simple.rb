
require 'rest-core/test'

describe RC::Simple do
  should 'work' do
    path = 'http://example.com'
    stub_request(:get, path).to_return(:body => 'OK')
    EM.run{Fiber.new{RC::Simple.new.get(path).should.eq 'OK'; EM.stop}.resume}
  end
end

