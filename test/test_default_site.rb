
require 'rest-core/test'

describe RC::DefaultSite do
  app = RC::DefaultSite.new(RC::Dry.new, 'http://example.com/')

  would 'leave site along if it already has a protocol' do
    app.call(RC::REQUEST_PATH => 'http://nnf.tw') do |res|
      res[RC::REQUEST_PATH].should.eq 'http://nnf.tw'
    end
  end

  would 'prepend the site if there is no protocol' do
    app.call(RC::REQUEST_PATH => 'nnf.tw') do |res|
      res[RC::REQUEST_PATH].should.eq 'http://example.com/nnf.tw'
    end
  end

  would 'not prepend duplicated /' do
    app.call(RC::REQUEST_PATH => '/nnf.tw') do |res|
      res[RC::REQUEST_PATH].should.eq 'http://example.com/nnf.tw'
    end
  end

  would 'concatenate site and path regardlessly' do
    app.call(RC::REQUEST_PATH => 'nnf.tw', 'site' => 'example.com') do |res|
      res[RC::REQUEST_PATH].should.eq 'example.com/nnf.tw'
    end
  end
end
