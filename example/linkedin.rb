
require 'rest-core'

linkedin = RestCore::Linkedin.new(:consumer_key    => '...',
                                  :consumer_secret => '...')
linkedin.authorize_url!   # copy and paste the URL in browser to authorize
linkedin.authorize!('..') # paste your code from browser
p linkedin.me             # get current user info
