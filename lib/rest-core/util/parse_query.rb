
module RestCore
  module ParseQuery
    module_function
    begin
      require 'rack/utils'
      def parse_query(qs, d = nil)
        Rack::Utils.parse_query(qs, d)
      end
    rescue LoadError
      require 'uri'
      # Stolen from Rack
      def parse_query(qs, d = nil)
        params = {}

        (qs || '').split(d ? /[#{d}] */n : /[&;] */n).each do |p|
          k, v = p.split('=', 2).map { |x| URI.decode_www_form_component(x) }
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
end
