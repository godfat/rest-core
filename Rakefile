
begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

Gemgem.init(dir) do |s|
  require 'rest-core/version'
  s.name    = 'rest-core'
  s.version = RestCore::VERSION
  %w[httpclient mime-types].each{ |g| s.add_runtime_dependency(g) }
  s.add_runtime_dependency('timers', '>=4.0.1')
end
