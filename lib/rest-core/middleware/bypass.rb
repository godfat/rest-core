
# the simplest middleware
module RestCore
  class Bypass
    def initialize app
      @app = app
    end

    def call env, &k
      @app.call(env, &k)
    end
  end
end
