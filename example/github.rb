
require 'rest-core'

p RestCore::Github.new.get('users/godfat') # get user info
