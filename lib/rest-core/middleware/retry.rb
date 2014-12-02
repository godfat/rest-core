
require 'rest-core/middleware'

class RestCore::Retry
  def self.members; [:max_retries]; end
  include RestCore::Middleware

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

    if idx = res[FAIL].index{ |f| f.kind_of?(Exception) }
      err = res[FAIL].delete_at(idx)
      env = res.merge('max_retries' => times - 1)
      call(log(env, Event::Retrying.new(
                      nil, "(#{times}) for: #{err.inspect}")), &k)
    else
      k.call(res)
    end
  end
end
