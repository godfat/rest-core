
begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

Gemgem.init(dir) do |s|
  require 'rest-core/version'
  s.name     = 'rest-core'
  s.version  = RestCore::VERSION
  s.homepage = 'https://github.com/godfat/rest-core'
  %w[timers mime-types httpclient].each{ |g| s.add_runtime_dependency(g) }
end
