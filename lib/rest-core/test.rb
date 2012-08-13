
require 'rest-core'

require 'rr'
require 'webmock'
require 'bacon'

# for testing lighten (serialization)
require 'yaml'

include RR::Adapters::RRMethods
include WebMock::API
WebMock.disable_net_connect!(:allow_localhost => true)
Bacon.summary_on_exit

module Kernel
  def eq? rhs
    self == rhs
  end

  def lt? rhs
    self < rhs
  end
end
