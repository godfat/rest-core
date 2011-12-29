
require 'rest-core/middleware'

class RestCore::JsonDecode
  def self.members; [:json_decode]; end
  include RestCore::Middleware

  def call env
    return app.call(env) if env[DRY]
    if env[ASYNC]
      app.call(env.merge(ASYNC => lambda{ |response|
        env[ASYNC].call(process(response))
      }))
    else
      process(app.call(env))
    end
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

  module Gsub
    class ParseError < RuntimeError; end
    def self.extended mod
      mod.const_set(:ParseError, Gsub::ParseError)
    end
    # only works for flat hash
    def json_encode hash
      middle = hash.inject([]){ |r, (k, v)|
                 r << "\"#{k}\":\"#{v.gsub('"','\\"')}\""
               }.join(',')
      "{#{middle}}"
    end
    def json_decode json
      raise NotImplementedError.new(
        'You need to install either yajl-ruby, json, or json_pure gem')
    end
  end

  def self.select_json! mod, picked=false
    if    Object.const_defined?(:Yajl)
      mod.send(:extend, YajlRuby)
    elsif Object.const_defined?(:JSON)
      mod.send(:extend, Json)
    elsif picked
      mod.send(:extend, Gsub)
    else
      # pick a json gem if available
      %w[yajl json].each{ |json|
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
