
require 'rest-core/middleware'

class RestCore::Dry
  include RestCore::Middleware
  def call env
    yield(env)
  end

  private
  def calculate_timeout timer
    return [] unless timer
    [timer.timeout, timer.timeout]
  end

  def normalize_headers headers
    headers.inject({}){ |r, (k, v)|
      r[k.to_s.upcase.tr('-', '_')] = if v.kind_of?(Array) && v.size == 1
                                        v.first
                                      else
                                        v
                                      end
      r
    }
  end
end
