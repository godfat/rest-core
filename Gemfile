
source 'https://rubygems.org/'

gemspec

gem 'rest-client'
gem 'em-http-request'

gem 'rake'
gem 'bacon'
gem 'muack'
gem 'webmock'

gem 'json'
gem 'json_pure'
gem 'multi_json'

gem 'rack'
gem 'ruby-hmac'

platforms :ruby do
  gem 'yajl-ruby'
end

platforms :rbx do
  gem 'rubysl-singleton' # used in rake
  gem 'rubysl-rexml'     # used in webmock used in crack
end

platforms :jruby do
  gem 'jruby-openssl'
end
