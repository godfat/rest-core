
require 'rest-core'

p RestCore::Github.new.get('users/cardinalblue') # get user info
