
source 'https://rubygems.org/'

gemspec

gem 'rest-builder', :path => 'rest-builder'
gem 'promise_pool', :path => 'rest-builder/promise_pool'

gem 'rake'
gem 'pork'
gem 'muack'
gem 'webmock'

gem 'json'
gem 'json_pure'
gem 'multi_json'

gem 'rack'

gem 'simplecov', :require => false if ENV['COV']
gem 'coveralls', :require => false if ENV['CI']

platforms :ruby do
  gem 'yajl-ruby'
end

platforms :jruby do
  gem 'jruby-openssl'
end
