
require 'em-http-request'
require 'restclient/payload'

require 'rest-core/engine/promise/promise'
require 'rest-core/middleware'

class RestCore::EmHttpRequest
  include RestCore::Middleware
  def call env, &k
    promise = Promise.create(env, k, env[ASYNC])
    promise.gofor{ request(promise, env) }

    env[TIMER].on_timeout{
      promise.reject(env[TIMER].error)
    } if env[TIMER]

    env.merge(RESPONSE_BODY    => promise.future_body,
              RESPONSE_STATUS  => promise.future_status,
              RESPONSE_HEADERS => promise.future_headers,
              PROMISE          => promise)
  end

  def request promise, env
    payload, headers = Payload.generate_with_headers(env[REQUEST_PAYLOAD],
                                                     env[REQUEST_HEADERS])
    args = if payload.nil?
             {}
           else
             tmpfile = payload2file(payload)
             if tmpfile.respond_to?(:path)
               {:file => tmpfile.path}
             else
               {:body => tmpfile}
             end
           end.merge(:head => headers)

    client = ::EventMachine::HttpRequest.new(request_uri(env)).
               send(env[REQUEST_METHOD], args)

    client.callback{
      close_tmpfile(tmpfile)
      promise.fulfill(client.response,
                      client.response_header.status,
                      client.response_header)}

    client.errback{
      close_client(client)
      close_tmpfile(tmpfile)
      promise.reject(client.error)}
  end

  def payload2file payload
    if payload.io.respond_to?(:path) # already a file
      payload.io

    elsif payload.size == 0 ||       # probably a socket, buffer to disc
          payload.size >= 81920      # probably too large, buffer to disc
      create_tmpfile(payload.io)

    else                             # probably not worth buffering to disc
      payload.read
    end
  end

  def create_tmpfile io
    tempfile = Tempfile.new("rest-core.em-http-request.#{rand(1_000_000)}")
    IO.copy_stream(io, tempfile)
    tempfile
  end

  def close_client client
    (client.instance_variable_get(:@callbacks)||[]).clear
    (client.instance_variable_get(:@errbacks )||[]).clear
    client.close
  end

  def close_tmpfile tmpfile
    if tmpfile.respond_to?(:close!)   # tempfile
      tmpfile.close!
    elsif tmpfile.respond_to?(:close) # regular IO
      tmpfile.close
    end
  end
end
