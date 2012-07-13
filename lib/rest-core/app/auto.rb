
require 'rest-core/middleware'

class RestCore::Auto
  include RestCore::Middleware
  def call env
    client = http_client
    client.call(log(env, "Auto picked: #{client.class}"))
  end

  def http_client
    if Object.const_defined?(:EventMachine) && ::EventMachine.reactor_running?
      @emhttprequest ||= RestCore::EmHttpRequest.new

    else
      @restclient    ||= RestCore::RestClient.new
    end
  end
end
