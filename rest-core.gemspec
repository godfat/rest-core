# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rest-core"
  s.version = "0.4.0.pre.1"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = [
  "Cardinal Blue",
  "Lin Jen-Shin (godfat)"]
  s.date = "2011-09-19"
  s.description = "A modular Ruby REST client collection/infrastructure\n\nIn this era of web services and mashups, we have seen a blooming of REST\nAPIs. One might wonder, how do we use these APIs easily and elegantly?\nSince REST is very simple compared to SOAP, it is not hard to build a\ndedicated client ourselves.\n\nWe have developed [rest-core][] with composable middlewares to build a\nREST client, based on the effort from [rest-graph][]. In the cases of\ncommon APIs such as Facebook, Github, and Twitter, developers can simply\nuse the built-in dedicated clients provided by rest-core, or do it yourself\nfor any other REST APIs.\n\n[rest-core]: http://github.com/cardinalblue/rest-core\n[rest-graph]: http://github.com/cardinalblue/rest-graph"
  s.email = ["dev (XD) cardinalblue.com"]
  s.executables = ["rib-rest-core"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  ".travis.yml",
  "CHANGES.md",
  "CONTRIBUTORS",
  "Gemfile",
  "LICENSE",
  "NOTE.md",
  "README.md",
  "Rakefile",
  "TODO.md",
  "bin/rib-rest-core",
  "example/facebook.rb",
  "example/github.rb",
  "example/linkedin.rb",
  "example/rails2/Gemfile",
  "example/rails2/README",
  "example/rails2/Rakefile",
  "example/rails2/app/controllers/application_controller.rb",
  "example/rails2/app/views/application/helper.html.erb",
  "example/rails2/config/boot.rb",
  "example/rails2/config/environment.rb",
  "example/rails2/config/environments/development.rb",
  "example/rails2/config/environments/production.rb",
  "example/rails2/config/environments/test.rb",
  "example/rails2/config/initializers/cookie_verification_secret.rb",
  "example/rails2/config/initializers/new_rails_defaults.rb",
  "example/rails2/config/initializers/session_store.rb",
  "example/rails2/config/preinitializer.rb",
  "example/rails2/config/rest-core.yaml",
  "example/rails2/config/routes.rb",
  "example/rails2/log",
  "example/rails2/test/functional/application_controller_test.rb",
  "example/rails2/test/test_helper.rb",
  "example/rails2/test/unit/rails_util_test.rb",
  "example/rails3/Gemfile",
  "example/rails3/README",
  "example/rails3/Rakefile",
  "example/rails3/app/controllers/application_controller.rb",
  "example/rails3/app/views/application/helper.html.erb",
  "example/rails3/config.ru",
  "example/rails3/config/application.rb",
  "example/rails3/config/environment.rb",
  "example/rails3/config/environments/development.rb",
  "example/rails3/config/environments/production.rb",
  "example/rails3/config/environments/test.rb",
  "example/rails3/config/initializers/secret_token.rb",
  "example/rails3/config/initializers/session_store.rb",
  "example/rails3/config/rest-core.yaml",
  "example/rails3/config/routes.rb",
  "example/rails3/test/functional/application_controller_test.rb",
  "example/rails3/test/test_helper.rb",
  "example/rails3/test/unit/rails_util_test.rb",
  "example/sinatra/config.ru",
  "example/twitter.rb",
  "lib/rest-core.rb",
  "lib/rest-core/app/dry.rb",
  "lib/rest-core/app/rest-client.rb",
  "lib/rest-core/builder.rb",
  "lib/rest-core/client.rb",
  "lib/rest-core/client/facebook.rb",
  "lib/rest-core/client/facebook/rails_util.rb",
  "lib/rest-core/client/flurry.rb",
  "lib/rest-core/client/flurry/rails_util.rb",
  "lib/rest-core/client/github.rb",
  "lib/rest-core/client/linkedin.rb",
  "lib/rest-core/client/mixi.rb",
  "lib/rest-core/client/simple.rb",
  "lib/rest-core/client/twitter.rb",
  "lib/rest-core/client/universal.rb",
  "lib/rest-core/client_oauth1.rb",
  "lib/rest-core/error.rb",
  "lib/rest-core/event.rb",
  "lib/rest-core/middleware.rb",
  "lib/rest-core/middleware/bypass.rb",
  "lib/rest-core/middleware/cache.rb",
  "lib/rest-core/middleware/common_logger.rb",
  "lib/rest-core/middleware/default_headers.rb",
  "lib/rest-core/middleware/default_query.rb",
  "lib/rest-core/middleware/default_site.rb",
  "lib/rest-core/middleware/defaults.rb",
  "lib/rest-core/middleware/error_detector.rb",
  "lib/rest-core/middleware/error_detector_http.rb",
  "lib/rest-core/middleware/error_handler.rb",
  "lib/rest-core/middleware/json_decode.rb",
  "lib/rest-core/middleware/oauth1_header.rb",
  "lib/rest-core/middleware/oauth2_header.rb",
  "lib/rest-core/middleware/oauth2_query.rb",
  "lib/rest-core/middleware/timeout.rb",
  "lib/rest-core/test.rb",
  "lib/rest-core/util/config.rb",
  "lib/rest-core/util/hmac.rb",
  "lib/rest-core/util/rails_util_util.rb",
  "lib/rest-core/util/vendor.rb",
  "lib/rest-core/version.rb",
  "lib/rest-core/wrapper.rb",
  "lib/rib/app/rest-core.rb",
  "pending/test_multi.rb",
  "pending/test_test_util.rb",
  "rest-core.gemspec",
  "task/.gitignore",
  "task/gemgem.rb",
  "test/client/facebook/config/rest-core.yaml",
  "test/client/facebook/test_api.rb",
  "test/client/facebook/test_cache.rb",
  "test/client/facebook/test_default.rb",
  "test/client/facebook/test_error.rb",
  "test/client/facebook/test_handler.rb",
  "test/client/facebook/test_load_config.rb",
  "test/client/facebook/test_misc.rb",
  "test/client/facebook/test_oauth.rb",
  "test/client/facebook/test_old.rb",
  "test/client/facebook/test_page.rb",
  "test/client/facebook/test_parse.rb",
  "test/client/facebook/test_serialize.rb",
  "test/client/facebook/test_timeout.rb",
  "test/client/flurry/test_metrics.rb",
  "test/client/twitter/test_api.rb",
  "test/test_builder.rb",
  "test/test_client.rb",
  "test/test_oauth1_header.rb",
  "test/test_wrapper.rb"]
  s.homepage = "https://github.com/cardinalblue/rest-core"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "A modular Ruby REST client collection/infrastructure"
  s.test_files = [
  "test/client/facebook/test_api.rb",
  "test/client/facebook/test_cache.rb",
  "test/client/facebook/test_default.rb",
  "test/client/facebook/test_error.rb",
  "test/client/facebook/test_handler.rb",
  "test/client/facebook/test_load_config.rb",
  "test/client/facebook/test_misc.rb",
  "test/client/facebook/test_oauth.rb",
  "test/client/facebook/test_old.rb",
  "test/client/facebook/test_page.rb",
  "test/client/facebook/test_parse.rb",
  "test/client/facebook/test_serialize.rb",
  "test/client/facebook/test_timeout.rb",
  "test/client/flurry/test_metrics.rb",
  "test/client/twitter/test_api.rb",
  "test/test_builder.rb",
  "test/test_client.rb",
  "test/test_oauth1_header.rb",
  "test/test_wrapper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
  end
end
