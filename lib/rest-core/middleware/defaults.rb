
require 'rest-core/middleware'

class RestCore::Defaults
  def self.members; [:defaults]; end
  include RestCore::Middleware

  # the use of singleton_class is making serialization hard!
  # def initialize app, defaults
  #   super
  #   singleton_class.module_eval do
  #     defaults.each{ |(key, value)|
  #       define_method(key) do |env|
  #         if value.respond_to?(:call)
  #           value.call
  #         else
  #           value
  #         end
  #       end
  #     }
  #   end
  # end

  def method_missing msg, *args, &block
    env = args.first
    if env.kind_of?(Hash) && (d = defaults(env)) && d.key?(msg)
      if (value = defaults(env)[msg]).respond_to?(:call)
        value.call
      else
        value
      end
    else
      super
    end
  end

  def respond_to? msg
    if (d = defaults({})) && d.key?(msg)
      true
    else
      super
    end
  end
end
