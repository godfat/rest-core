
require 'rest-core'

require 'rr'
require 'webmock'
require 'bacon'

# for testing lighten (serialization)
require 'yaml'

include RR::Adapters::RRMethods
include WebMock::API
WebMock.disable_net_connect!
Bacon.summary_on_exit

module TestHelper
  module_function
  def normalize_query query
    '?' + query[1..-1].split('&').sort.join('&')
  end

  def normalize_url url
    url.sub(/\?.+/){ |query| TestHelper.normalize_query(query) }
  end
end

module Kernel
  def eq? rhs
    self == rhs
  end

  def lt? rhs
    self < rhs
  end
end
