
require 'rest-core'
RestCore::Twitter.new.statuses('godfat') # get user tweets

twitter = RestCore::Twitter.new(:consumer_key    => '...',
                                :consumer_secret => '...')
twitter.authorize_url!   # copy and paste the URL in browser to authorize
twitter.authorize!('..') # paste your code from browser
p twitter.tweet('hi!')   # tweet for the current user

p twitter.post('statuses/update_with_media.json',
  :status => 'hi!', 'media[]' => File.open('...'))
