
begin
  require "#{__dir__}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

Gemgem.init(__dir__, :submodules =>
  %w[rest-builder
     rest-builder/promise_pool]) do |s|
  require 'rest-core/version'
  s.name    = 'rest-core'
  s.version = RestCore::VERSION

  %w[rest-builder].each(&s.method(:add_runtime_dependency))
end

desc 'Run console'
task 'console' do
  ARGV.shift
  load `which rib`.chomp
end
