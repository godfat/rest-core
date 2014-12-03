
require 'rest-core/middleware'

class RestCore::Retry
  def self.members; [:max_retries, :retry_exceptions]; end
  include RestCore::Middleware

  DefaultRetryExceptions = [IOError, SystemCallError]

  def call env, &k
    if env[DRY]
      app.call(env, &k)
    else
      app.call(env){ |res| process(res, k) }
    end
  end

  def process res, k
    times = max_retries(res)
    return k.call(res) if times <= 0
    errors = retry_exceptions(res) || DefaultRetryExceptions

    if idx = res[FAIL].index{ |f| errors.find{ |e| f.kind_of?(e) } }
      err = res[FAIL].delete_at(idx)
      error_callback(res, err)
      env = res.merge('max_retries' => times - 1)
      give_promise(call(log(
        env, Event::Retrying.new(nil, "(#{times}) for: #{err.inspect}")), &k))
    else
      k.call(res)
    end
  end

  def error_callback res, err
    res[CLIENT].error_callback.call(err) if
      res[CLIENT] && res[CLIENT].error_callback
  end

  def give_promise res
    res[CLIENT].give_promise(res) if res[CLIENT]
  end
end
