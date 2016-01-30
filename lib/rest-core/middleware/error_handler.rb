
module RestCore
  class ErrorHandler
    def self.members; [:error_handler]; end
    include Middleware

    def call env
      app.call(env){ |res|
        h = error_handler(res)
        f = res[FAIL] || []
        yield(if f.empty? || f.find{ |ff| ff.kind_of?(Exception) } || !h
                res
              else
                fail(res, h.call(res))
              end)}
    end
  end
end
