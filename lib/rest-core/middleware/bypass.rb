
module RestCore; end

# the simplest middleware
class RestCore::Bypass
  def initialize app
    @app = app
  end

  def call env, &k
    @app.call(env, &k)
  end
end
