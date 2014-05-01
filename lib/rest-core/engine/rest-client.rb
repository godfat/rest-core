
require 'restclient'
require 'rest-core/patch/rest-client'
require 'rest-core/engine'

class RestCore::RestClient < RestCore::Engine
  def request promise, env
    open_timeout, read_timeout = calculate_timeout(env[TIMER])
    payload, headers = payload_and_headers(env)
    res = ::RestClient::Request.execute(:method   => env[REQUEST_METHOD],
                                        :url      => request_uri(env)   ,
                                        :payload  => payload            ,
                                        :headers  => headers            ,
                                        :max_redirects => 0             ,
                                        :open_timeout => open_timeout   ,
                                             :timeout => read_timeout   )
    promise.fulfill(res.body, res.code, normalize_headers(res.raw_headers))

  rescue ::RestClient::RequestTimeout
    promise.reject((env[TIMER] && env[TIMER].error) ||
                   ::Timeout::Error.new('execution expired'))

  rescue ::RestClient::Exception => e
    if res = e.response
      # we don't want to raise an exception for 404 requests
      promise.fulfill(res.body, res.code, normalize_headers(res.raw_headers))
    else
      promise.reject(e)
    end

  rescue Exception => e
    promise.reject(e)
  end
end
