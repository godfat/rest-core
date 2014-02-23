
require 'rest-core/middleware'

class RestCore::Auto
  include RestCore::Middleware
  def call env, &k
    client = http_client
    client.call(log(env, "Auto    picked: #{client.class}"), &k)
  end

  def http_client
    if         Object.const_defined?(:EventMachine) &&
       ::EventMachine.const_defined?(:HttpRequest)  &&
       ::EventMachine.reactor_running?              &&
       # it should be either wrapped around a thread or a fiber
       ((Thread.main != Thread.current) ||
        (Fiber.respond_to?(:current) && RootFiber != Fiber.current))

      @emhttprequest ||= RestCore::EmHttpRequest.new

    else
      @restclient    ||= RestCore::RestClient.new
    end
  end
end
