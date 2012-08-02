
require 'rest-core'

require 'cgi'

module RestCore::Middleware
  include RestCore

  # identity function
  def self.id
    @id ||= lambda{ |a| a }
  end

  def self.included mod
    mod.send(:include, RestCore)
    mod.send(:attr_reader, :app)
    mem = if mod.respond_to?(:members) then mod.members else [] end
    src = mem.map{ |member| <<-RUBY }
      def #{member} env
        if    env.key?('#{member}')
          env['#{member}']
        else
              @#{member}
        end
      end
    RUBY
    args      = [:app] + mem
    para_list = args.map{ |a| "#{a}=nil"}.join(', ')
    args_list = args                     .join(', ')
    ivar_list = args.map{ |a| "@#{a}"   }.join(', ')
    src << <<-RUBY
      def initialize #{para_list}
        #{ivar_list} = #{args_list}
      end
    RUBY
    accessor = Module.new
    accessor.module_eval(src.join("\n"), __FILE__, __LINE__)
    mod.const_set(:Accessor, accessor)
    mod.send(:include, accessor)
  end

  def call env,  &k; app.call(env, &(k || id))                   ; end
  def fail env, obj; env.merge(FAIL => (env[FAIL] || []) + [obj]); end
  def log  env, obj; env.merge(LOG  => (env[LOG]  || []) + [obj]); end
  def id           ; Middleware.id                               ; end
  def run app=app
    if app.respond_to?(:app) && app.app
      run(app.app)
    else
      app
    end
  end

  module_function
  def request_uri env
    # compacting the hash
    if (query = (env[REQUEST_QUERY] || {}).select{ |k, v| v }).empty?
      env[REQUEST_PATH].to_s
    else
      q = if env[REQUEST_PATH] =~ /\?/ then '&' else '?' end
      "#{env[REQUEST_PATH]}#{q}" \
      "#{query.sort.map{ |(k, v)|
        "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')}"
    end
  end
  public :request_uri

  def string_keys hash
    hash.inject({}){ |r, (k, v)|
      if v.kind_of?(Hash)
        r[k.to_s] = case k.to_s
                      when REQUEST_QUERY, REQUEST_PAYLOAD, REQUEST_HEADERS
                        string_keys(v)
                      else;         v
                    end
      else
        r[k.to_s] = v
      end
      r
    }
  end
  public :string_keys
end
