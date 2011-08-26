
require 'rest-core'
RestCore::Twitter.new.statuses('_cardinalblue') # get user tweets

twitter = RestCore::Twitter.new(:consumer_key    => '...',
                                :consumer_secret => '...')
twitter.authorize_url!   # copy and paste the URL in browser to authorize
twitter.authorize!('..') # paste your code from browser
p twitter.tweet('hi!')   # tweet for the current user

p twitter.tweet('hi with pic!', File.open('...'))
