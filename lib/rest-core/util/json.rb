
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
  end
end
