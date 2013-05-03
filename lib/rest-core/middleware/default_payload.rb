
require 'rest-core/middleware'

class RestCore::DefaultPayload
  def self.members; [:payload]; end
  include RestCore::Middleware

  def initialize *args
    super
    @payload ||= {}
  end

  def call env, &k
    defaults = merge(@payload, payload(env))

    app.call(env.merge(REQUEST_PAYLOAD =>
      merge(defaults, env[REQUEST_PAYLOAD])), &k)
  end

  # this method is intended to merge payloads if they are non-empty hashes,
  # but prefer the right most one if they are not hashes.
  def merge lhs, rhs
    if rhs.respond_to?(:empty?) && rhs.empty?
      lhs
    elsif lhs.respond_to?(:merge)
      if rhs.respond_to?(:merge)
        string_keys(lhs).merge(string_keys(rhs))
      else
        rhs
      end
    else
      rhs
    end
  end
end
