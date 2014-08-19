
require 'rest-core/test'

describe RC::DefaultHeaders do
  app = RC::DefaultHeaders.new(RC::Dry.new, 'a' => 'b')

  would 'also merge the very default headers' do
    app.call('headers' => {'b' => 'c'},
             RC::REQUEST_HEADERS => {'c' => 'd'}) do |r|
      r[RC::REQUEST_HEADERS].should.eq 'a' => 'b', 'b' => 'c', 'c' => 'd'
    end
  end
end
