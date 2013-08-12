# encoding: utf-8

begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh "git submodule update --init"
  exec Gem.ruby, "-S", "rake", *ARGV
end

Gemgem.dir = dir
($LOAD_PATH << File.expand_path("#{Gemgem.dir}/lib" )).uniq!

desc 'Generate gemspec'
task 'gem:spec' do
  Gemgem.spec = Gemgem.create do |s|
    require 'rest-core/version'
    s.name     = 'rest-core'
    s.version  = RestCore::VERSION
    s.homepage = 'https://github.com/godfat/rest-core'

    %w[rest-client].each{ |g| s.add_runtime_dependency(g) }

    s.authors  = ['Cardinal Blue', 'Lin Jen-Shin (godfat)']

    s.post_install_message = <<-MARKDOWN
# [rest-core] Since 2.1.0, Incompatible changes for POST requests:

* We no longer support Rails-like POST payload, like translating
  `{:foo => [1, 2]}` to `'foo[]=1&foo[]=2'`. It would now be translated to
  `'foo=1&foo=2'`. If you like `'foo[]'` as the key, simply pass it as
  `{'foo[]' => [1, 2]}`.

* This also applies to nested hashes like `{:foo => {:bar => 1}`. If you
  want that behaviour, just pass `{'foo[bar]' => 1}` which would then be
  translated to `'foo[bar]=1'`.
MARKDOWN
  end

  Gemgem.write
end
