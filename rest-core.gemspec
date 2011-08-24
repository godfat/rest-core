# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rest-core}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [
  %q{Cardinal Blue},
  %q{Lin Jen-Shin (godfat)}]
  s.date = %q{2011-08-25}
  s.description = %q{A modular Ruby REST client collection/infrastructure.

In this era of web services and mashups, we have seen a blooming of REST
APIs. One might wonder, how do we use these APIs easily and elegantly?
Since REST is very simple compared to SOAP, it is not hard to build a
dedicated client ourselves.

We have developed [rest-core][] with composable middlewares to build a
REST client, based on the effort from [rest-graph][]. In the cases of
common APIs such as Facebook, Github, and Twitter, developers can simply
use the built-in dedicated clients provided by rest-core, or do it yourself
for any other REST APIs.

[rest-core]: http://github.com/cardinalblue/rest-core
[rest-graph]: http://github.com/cardinalblue/rest-graph}
  s.email = [%q{dev (XD) cardinalblue.com}]
  s.files = [
  %q{.gitignore},
  %q{.gitmodules},
  %q{.travis.yml},
  %q{CHANGES.md},
  %q{CONTRIBUTORS},
  %q{Gemfile},
  %q{LICENSE},
  %q{NOTE.md},
  %q{README.md},
  %q{Rakefile},
  %q{TODO.md},
  %q{example/facebook.rb},
  %q{example/github.rb},
  %q{example/linkedin.rb},
  %q{example/twitter.rb},
  %q{lib/rest-core.rb},
  %q{lib/rest-core/app/ask.rb},
  %q{lib/rest-core/app/rest-client.rb},
  %q{lib/rest-core/builder.rb},
  %q{lib/rest-core/client.rb},
  %q{lib/rest-core/client/github.rb},
  %q{lib/rest-core/client/linkedin.rb},
  %q{lib/rest-core/client/rest-graph.rb},
  %q{lib/rest-core/client/twitter.rb},
  %q{lib/rest-core/client_oauth1.rb},
  %q{lib/rest-core/event.rb},
  %q{lib/rest-core/middleware.rb},
  %q{lib/rest-core/middleware/cache.rb},
  %q{lib/rest-core/middleware/common_logger.rb},
  %q{lib/rest-core/middleware/default_headers.rb},
  %q{lib/rest-core/middleware/default_query.rb},
  %q{lib/rest-core/middleware/default_site.rb},
  %q{lib/rest-core/middleware/defaults.rb},
  %q{lib/rest-core/middleware/error_detector.rb},
  %q{lib/rest-core/middleware/error_detector_http.rb},
  %q{lib/rest-core/middleware/error_handler.rb},
  %q{lib/rest-core/middleware/json_decode.rb},
  %q{lib/rest-core/middleware/oauth1_header.rb},
  %q{lib/rest-core/middleware/oauth2_query.rb},
  %q{lib/rest-core/middleware/timeout.rb},
  %q{lib/rest-core/util/config.rb},
  %q{lib/rest-core/util/hmac.rb},
  %q{lib/rest-core/version.rb},
  %q{lib/rest-core/wrapper.rb},
  %q{pending/test_multi.rb},
  %q{pending/test_test_util.rb},
  %q{rest-core.gemspec},
  %q{task/.gitignore},
  %q{task/gemgem.rb},
  %q{test/common.rb},
  %q{test/config/rest-core.yaml},
  %q{test/test_api.rb},
  %q{test/test_cache.rb},
  %q{test/test_default.rb},
  %q{test/test_error.rb},
  %q{test/test_handler.rb},
  %q{test/test_load_config.rb},
  %q{test/test_misc.rb},
  %q{test/test_oauth.rb},
  %q{test/test_oauth1_header.rb},
  %q{test/test_old.rb},
  %q{test/test_page.rb},
  %q{test/test_parse.rb},
  %q{test/test_serialize.rb},
  %q{test/test_timeout.rb}]
  s.homepage = %q{https://github.com/cardinalblue/rest-core}
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.7}
  s.summary = %q{A modular Ruby REST client collection/infrastructure.}
  s.test_files = [
  %q{test/test_api.rb},
  %q{test/test_cache.rb},
  %q{test/test_default.rb},
  %q{test/test_error.rb},
  %q{test/test_handler.rb},
  %q{test/test_load_config.rb},
  %q{test/test_misc.rb},
  %q{test/test_oauth.rb},
  %q{test/test_oauth1_header.rb},
  %q{test/test_old.rb},
  %q{test/test_page.rb},
  %q{test/test_parse.rb},
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
