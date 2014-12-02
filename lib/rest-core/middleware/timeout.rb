
require 'timeout'

require 'rest-core/middleware'
require 'rest-core/timer'

class RestCore::Timeout
  def self.members; [:timeout]; end
  include RestCore::Middleware

  def call env, &k
    return app.call(env, &k) if env[DRY] || timeout(env) == 0
    monitor(env){ |e|
      app.call(e){ |r|
        if r[ASYNC] ||
           !(exp = (r[FAIL]||[]).find{ |f| f.kind_of?(::Timeout::Error) })
          # we do nothing special for callback and rest-client
          k.call(r)
        else
          # it would go to this branch only under response future
          raise exp
        end}}
  end

  def monitor env
    timer = Timer.new(timeout(env), timeout_error)
    yield(env.merge(TIMER => timer))
  rescue Exception
    timer.cancel
    raise
  end

  def timeout_error
    ::Timeout::Error.new('execution expired')
  end
end
