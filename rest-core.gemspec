# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rest-core}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [
  %q{Cardinal Blue},
  %q{Lin Jen-Shin (godfat)}]
  s.date = %q{2011-05-26}
  s.description = %q{A modular Ruby REST client interface}
  s.email = [%q{dev (XD) cardinalblue.com}]
  s.extra_rdoc_files = [
  %q{CHANGES},
  %q{CONTRIBUTORS},
  %q{LICENSE},
  %q{TODO}]
  s.files = [
  %q{.gitignore},
  %q{.gitmodules},
  %q{CONTRIBUTORS},
  %q{Gemfile},
  %q{LICENSE},
  %q{README},
  %q{README.md},
  %q{Rakefile},
  %q{lib/rest-core.rb},
  %q{lib/rest-core/app/rest-client.rb},
  %q{lib/rest-core/builder.rb},
  %q{lib/rest-core/client.rb},
  %q{lib/rest-core/client/rest-graph.rb},
  %q{lib/rest-core/event.rb},
  %q{lib/rest-core/middleware.rb},
  %q{lib/rest-core/middleware/cache.rb},
  %q{lib/rest-core/middleware/common_logger.rb},
  %q{lib/rest-core/middleware/default_headers.rb},
  %q{lib/rest-core/middleware/default_site.rb},
  %q{lib/rest-core/middleware/error_detector.rb},
  %q{lib/rest-core/middleware/error_handler.rb},
  %q{lib/rest-core/middleware/json_decode.rb},
  %q{lib/rest-core/middleware/timeout.rb},
  %q{lib/rest-core/version.rb},
  %q{lib/rest-graph/config_util.rb},
  %q{task/gemgem.rb},
  %q{test/common.rb},
  %q{test/config/rest-graph.yaml},
  %q{test/test_api.rb},
  %q{test/test_cache.rb},
  %q{test/test_default.rb},
  %q{test/test_error.rb},
  %q{test/test_facebook.rb},
  %q{test/test_handler.rb},
  %q{test/test_load_config.rb},
  %q{test/test_misc.rb},
  %q{test/test_multi.rb},
  %q{test/test_oauth.rb},
  %q{test/test_old.rb},
  %q{test/test_page.rb},
  %q{test/test_parse.rb},
  %q{test/test_rest-graph.rb},
  %q{test/test_serialize.rb},
  %q{test/test_test_util.rb},
  %q{test/test_timeout.rb},
  %q{CHANGES},
  %q{TODO}]
  s.homepage = %q{https://github.com/godfat/}
  s.rdoc_options = [
  %q{--main},
  %q{README}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.4}
  s.summary = %q{A modular Ruby REST client interface}
  s.test_files = [
  %q{test/test_api.rb},
  %q{test/test_cache.rb},
  %q{test/test_default.rb},
  %q{test/test_error.rb},
  %q{test/test_facebook.rb},
  %q{test/test_handler.rb},
  %q{test/test_load_config.rb},
  %q{test/test_misc.rb},
  %q{test/test_multi.rb},
  %q{test/test_oauth.rb},
  %q{test/test_old.rb},
  %q{test/test_page.rb},
  %q{test/test_parse.rb},
  %q{test/test_rest-graph.rb},
  %q{test/test_serialize.rb},
  %q{test/test_test_util.rb},
  %q{test/test_timeout.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rest-client>, [">= 0"])
      s.add_development_dependency(%q<em-http-request>, [">= 0"])
      s.add_development_dependency(%q<rack>, [">= 0"])
      s.add_development_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<json_pure>, [">= 0"])
      s.add_development_dependency(%q<ruby-hmac>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
      s.add_development_dependency(%q<bacon>, [">= 0"])
      s.add_development_dependency(%q<rr>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<em-http-request>, [">= 0"])
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<ruby-hmac>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
      s.add_dependency(%q<bacon>, [">= 0"])
      s.add_dependency(%q<rr>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<em-http-request>, [">= 0"])
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<yajl-ruby>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<ruby-hmac>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
    s.add_dependency(%q<bacon>, [">= 0"])
    s.add_dependency(%q<rr>, [">= 0"])
  end
end
