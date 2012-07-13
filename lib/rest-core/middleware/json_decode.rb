
require 'rest-core/middleware'

class RestCore::JsonDecode
  def self.members; [:json_decode]; end
  include RestCore::Middleware

  def call env, &k
    return app.call(env, &k) if env[DRY]
    app.call(env){ |response|
      yield(process(response))
    }
  end

  def process response
    if json_decode(response)
      response.merge(RESPONSE_BODY =>
        self.class.json_decode("[#{response[RESPONSE_BODY]}]").first)
        # [this].first is not needed for yajl-ruby
    else
      response
    end
  rescue self.class.const_get(:ParseError) => error
    fail(response, error)
  end

  module MultiJson
    def self.extended mod
      mod.const_set(:ParseError, ::MultiJson::DecodeError)
    end
    def json_encode hash
      ::MultiJson.dump(hash)
    end
    def json_decode json
      ::MultiJson.load(json)
    end
  end

  module YajlRuby
    def self.extended mod
      mod.const_set(:ParseError, Yajl::ParseError)
    end
    def json_encode hash
      Yajl::Encoder.encode(hash)
    end
    def json_decode json
      Yajl::Parser.parse(json)
    end
  end

  module Json
    def self.extended mod
      mod.const_set(:ParseError, JSON::ParserError)
    end
    def json_encode hash
      JSON.dump(hash)
    end
    def json_decode json
      JSON.parse(json)
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
