# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rest-core}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [
  %q{Cardinal Blue},
  %q{Lin Jen-Shin (godfat)}]
  s.date = %q{2011-06-22}
  s.description = %q{A modular Ruby REST client collection/infrastructure.

In an era of web service and mashup, we saw a blooming of REST API. One might
wonder, how do we easily and elegantly use those API? Thanks that now we are
all favoring REST over SOAP, building a dedicated client might not be that
hard. So why not just build the dedicated clients ourselves?

One can simply use pre-built dedicated clients provided by rest-core,
assuming this would be the most cases. Or if someone is not satisfied with
the pre-built ones, one can use pre-built "middlewares" and "apps" provided
by rest-core, to compose and build the dedicated "clients" (s)he prefers.}
  s.email = [%q{dev (XD) cardinalblue.com}]
  s.extra_rdoc_files = [
  %q{CHANGES},
  %q{CONTRIBUTORS},
  %q{LICENSE},
  %q{TODO}]
  s.files = [
  %q{.gitignore},
  %q{.gitmodules},
  %q{.travis.yml},
  %q{CONTRIBUTORS},
  %q{Gemfile},
  %q{LICENSE},
  %q{NOTE.md},
  %q{README},
  %q{README.md},
  %q{Rakefile},
  %q{lib/rest-core.rb},
  %q{lib/rest-core/app/ask.rb},
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
  %q{lib/rest-core/middleware/defaults.rb},
  %q{lib/rest-core/middleware/error_detector.rb},
  %q{lib/rest-core/middleware/error_handler.rb},
  %q{lib/rest-core/middleware/json_decode.rb},
  %q{lib/rest-core/middleware/oauth_token.rb},
  %q{lib/rest-core/middleware/timeout.rb},
  %q{lib/rest-core/version.rb},
  %q{lib/rest-core/wrapper.rb},
  %q{lib/rest-graph/config_util.rb},
  %q{rest-core.gemspec},
  %q{task/.gitignore},
  %q{task/gemgem.rb},
  %q{test/common.rb},
  %q{test/config/rest-graph.yaml},
  %q{test/pending/test_load_config.rb},
  %q{test/pending/test_multi.rb},
  %q{test/pending/test_test_util.rb},
  %q{test/test_api.rb},
  %q{test/test_cache.rb},
  %q{test/test_default.rb},
  %q{test/test_error.rb},
  %q{test/test_handler.rb},
  %q{test/test_misc.rb},
  %q{test/test_oauth.rb},
  %q{test/test_old.rb},
  %q{test/test_page.rb},
  %q{test/test_parse.rb},
  %q{test/test_rest-graph.rb},
  %q{test/test_serialize.rb},
  %q{test/test_timeout.rb},
  %q{CHANGES},
  %q{TODO}]
  s.homepage = %q{https://github.com/cardinalblue/rest-core}
  s.rdoc_options = [
  %q{--main},
  %q{README}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{A modular Ruby REST client collection/infrastructure.}
  s.test_files = [
  %q{test/pending/test_load_config.rb},
  %q{test/pending/test_multi.rb},
  %q{test/pending/test_test_util.rb},
  %q{test/test_api.rb},
  %q{test/test_cache.rb},
  %q{test/test_default.rb},
  %q{test/test_error.rb},
  %q{test/test_handler.rb},
  %q{test/test_misc.rb},
  %q{test/test_oauth.rb},
  %q{test/test_old.rb},
  %q{test/test_page.rb},
  %q{test/test_parse.rb},
  %q{test/test_rest-graph.rb},
  %q{test/test_serialize.rb},
  %q{test/test_timeout.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rest-client>, [">= 0"])
      s.add_development_dependency(%q<rack>, [">= 0"])
      s.add_development_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<json_pure>, [">= 0"])
      s.add_development_dependency(%q<ruby-hmac>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
      s.add_development_dependency(%q<bacon>, [">= 0"])
      s.add_development_dependency(%q<rr>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<ruby-hmac>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
      s.add_dependency(%q<bacon>, [">= 0"])
      s.add_dependency(%q<rr>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<yajl-ruby>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<ruby-hmac>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
    s.add_dependency(%q<bacon>, [">= 0"])
    s.add_dependency(%q<rr>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
