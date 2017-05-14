
module RestCore
  module Json
    module MultiJson
      def self.extended mod
        mod.const_set(:ParseError, ::MultiJson::DecodeError)
      end
      def encode hash
        ::MultiJson.dump(hash)
      end
      def decode json
        ::MultiJson.load(json)
      end
    end

    module YajlRuby
      def self.extended mod
        mod.const_set(:ParseError, Yajl::ParseError)
      end
      def encode hash
        Yajl::Encoder.encode(hash)
      end
      def decode json
        Yajl::Parser.parse(json)
      end
    end

    module Json
      def self.extended mod
        mod.const_set(:ParseError, JSON::ParserError)
      end
      def encode hash
        JSON.dump(hash)
      end
      def decode json
        JSON.parse(json, :quirks_mode => true)
      end
    end

    def self.select_json! mod, picked=false
      if    Object.const_defined?(:MultiJson)
        mod.send(:extend, MultiJson)
      elsif Object.const_defined?(:Yajl)
        mod.send(:extend, YajlRuby)
      elsif Object.const_defined?(:JSON)
        mod.send(:extend, Json)
      elsif picked
        raise LoadError.new(
          'No JSON library found. Tried: multi_json, yajl-ruby, json.')
      else
        # pick a json gem if available
        %w[multi_json yajl json].each{ |json|
          begin
            require json
            break
          rescue LoadError
          end
        }
        select_json!(mod, true)
      end
    end

    select_json!(self)

    def self.normalize json
      empty_to_null(strip_bom(json))
    end

    def self.strip_bom json
      case json.encoding.name
      when 'UTF-8'
        # StackExchange returns the problematic BOM! in UTF-8, so we
        # need to strip it or it would break JSON parsers (i.e.
        # yajl-ruby and json)
        json.sub(/\A\xEF\xBB\xBF/u, '')
      when 'ASCII-8BIT'
        # In case if Content-Type doesn't have a charset for UTF-8,
        # httpclient would set the response to ASCII-8BIT in this
        # case.
        json.sub(/\A\xEF\xBB\xBF/n, '')
      else
        json
      end
    end

    def self.empty_to_null json
      if json.empty?
        'null'
      else
        json
      end
    end
  end
end
