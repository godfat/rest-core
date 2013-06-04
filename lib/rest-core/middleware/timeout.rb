
require 'rest-core/middleware'

require 'timeout'

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
    class_name = case name = run.class.to_s
                 when /Auto/
                   run.http_client.class.to_s
                 else
                   name
                 end

    timer = case class_name
            when /EmHttpRequest/
              TimerEm
            else
              TimerThread
            end.new(timeout(env), timeout_error)

    yield(env.merge(TIMER => timer))
  rescue Exception
    timer.cancel
    raise
  end

  def timeout_error
    ::Timeout::Error.new('execution expired')
  end

  autoload :TimerEm    , 'rest-core/middleware/timeout/timer_em'
  autoload :TimerThread, 'rest-core/middleware/timeout/timer_thread'
end
