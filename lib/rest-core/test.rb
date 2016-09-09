
require 'rest-core'

require 'pork/auto'
require 'muack'
require 'webmock'

WebMock.enable!
WebMock.disable_net_connect!(:allow_localhost => true)
Pork::Suite.include(Muack::API, WebMock::API)
