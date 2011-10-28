
module RestCore; end
module RestCore::ParseQuery
  module_function
  begin
    require 'rack/utils'
    def parse_query(qs, d = nil)
      Rack::Utils.parse_query(qs, d)
    end
  rescue LoadError
    # Stolen from Rack
    def parse_query(qs, d = nil)
      params = {}

      (qs || '').split(d ? /[#{d}] */n : DEFAULT_SEP).each do |p|
        k, v = p.split('=', 2).map { |x| unescape(x) }
        if cur = params[k]
          if cur.class == Array
            params[k] << v
          else
            params[k] = [cur, v]
          end
        else
          params[k] = v
        end
      end

      return params
    end
  end
end
