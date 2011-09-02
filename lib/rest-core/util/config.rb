
require 'erb'
require 'yaml'

module RestCore; end
module RestCore::Config
  extend self

  DefaultModuleName = 'DefaultAttributes'

  def load_for_rails klass, app=Rails
    root = File.expand_path(app.root)
    path = ["#{root}/config/rest-core.yaml", # YAML should use .yaml
            "#{root}/config/rest-core.yml" ].find{|p| File.exist?(p)}
    RestCore::Config.load(klass, path, app.env)
  end

  def load klass, path, env
    config   = YAML.load(ERB.new(File.read(path)).result(binding))
    defaults = config[env]
    return false unless defaults
    raise ArgumentError.new("#{defaults} is not a hash") unless
      defaults.kind_of?(Hash)

    mod = if klass.const_defined?(DefaultModuleName)
            klass.const_get(DefaultModuleName)
          else
            klass.send(:const_set, DefaultModuleName, Module.new)
          end

    singleton_class = if klass.respond_to?(:singleton_class)
                        klass.singleton_class
                      else
                        class << klass; self; end
                      end

    klass.send(:extend, mod) unless singleton_class < mod

    mod.module_eval(defaults.inject(["extend self\n"]){ |r, (k, v)|
      # quote strings, leave others free (e.g. false, numbers, etc)
      r << <<-RUBY
        def default_#{k}
          #{v.kind_of?(String) ? "'#{v}'" : v}
        end
      RUBY
    }.join, __FILE__, __LINE__)
  end
end
