
require 'rest-core'

require 'pork/auto'
require 'muack'
require 'webmock'

# for testing lighten (serialization)
require 'yaml'

WebMock.disable_net_connect!(:allow_localhost => true)
Pork::Executor.include(Muack::API, WebMock::API)
