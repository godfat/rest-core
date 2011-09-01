
require 'sinatra'
require 'rest-core'

app_id = '123'
secret = 'abc'
config = {:app_id => app_id,
          :secret => secret}

post '/' do
  fb = RestCore::Facebook.new(config)
  fb.parse_signed_request!(params['signed_request'])
  "#{fb.get('me').inspect.gsub('<', '&lt;')}\n"
end

run Sinatra::Application
