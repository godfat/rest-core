
require 'rest-core/middleware'

class RestCore::Auto
  include RestCore::Middleware
  def call env, &k
    client = http_client
    client.call(log(env, "Auto    picked: #{client.class}"), &k)
  end

  def http_client
    @restclient ||= RestCore::RestClient.new
  end
end
