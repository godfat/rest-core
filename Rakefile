# encoding: utf-8

require "#{dir = File.dirname(__FILE__)}/task/gemgem"
Gemgem.dir = dir

($LOAD_PATH << File.expand_path("#{Gemgem.dir}/lib" )).uniq!

desc 'Generate gemspec'
task 'gem:spec' do
  Gemgem.spec = Gemgem.create do |s|
    require 'rest-core/version'
    s.name        = 'rest-core'
    s.version     = RestCore::VERSION
    # s.executables = [s.name]

    %w[].each{ |g| s.add_runtime_dependency(g) }
    %w[rest-client em-http-request rack yajl-ruby json json_pure ruby-hmac
       webmock bacon rr].each{ |g| s.add_development_dependency(g) }

    s.authors     = ['Cardinal Blue', 'Lin Jen-Shin (godfat)']
    s.email       = ['dev (XD) cardinalblue.com']
  end

  Gemgem.write
end
