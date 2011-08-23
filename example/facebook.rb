
require 'rest-core/client/rest-graph'

p RestGraph.new.get('4') # get user info

facebook = RestGraph.new(:app_id => '...', :secret => '...')
facebook.authorize_url # copy and paste the URL in browser to authorize
facebook.authorize!(:redirect_uri => '...', :code => '...')
p facebook.get('me')
