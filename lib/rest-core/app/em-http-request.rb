
require 'rest-core/middleware'

require 'em-http-request'

class RestCore::EmHttpRequest
  include RestCore::Middleware
  def call env
    client = EventMachine::HttpRequest.new(request_uri(env)).send(
      env[REQUEST_METHOD], :body => env[REQUEST_PAYLOAD],
                           :head => env[REQUEST_HEADERS])
    client.callback{
      env[ASYNC].call(env.merge(RESPONSE_BODY    => client.response,
                                RESPONSE_STATUS  => client.status  ,
                                RESPONSE_HEADERS => client.headers))
    }

    env
  end
end
