# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rest-core"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [
  "Cardinal Blue",
  "Lin Jen-Shin (godfat)"]
  s.date = "2012-07-13"
  s.description = "Modular Ruby clients interface for REST APIs\n\nThere has been an explosion in the number of REST APIs available today.\nTo address the need for a way to access these APIs easily and elegantly,\nwe have developed [rest-core][], which consists of composable middleware\nthat allows you to build a REST client for any REST API. Or in the case of\ncommon APIs such as Facebook, Github, and Twitter, you can simply use the\ndedicated clients provided by [rest-more][].\n\n[rest-core]: https://github.com/cardinalblue/rest-core\n[rest-more]: https://github.com/cardinalblue/rest-more"
  s.email = ["dev (XD) cardinalblue.com"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  ".travis.yml",
  "CHANGES.md",
  "Gemfile",
  "LICENSE",
  "NOTE.md",
  "README.md",
  "Rakefile",
  "TODO.md",
  "doc/ToC.md",
  "doc/dependency.md",
  "doc/design.md",
  "example/auto.rb",
  "example/eventmachine.rb",
  "example/future.rb",
  "example/multi.rb",
  "example/rest-client.rb",
  "lib/rest-core.rb",
  "lib/rest-core/app/abstract/response_future.rb",
  "lib/rest-core/app/auto.rb",
  "lib/rest-core/app/dry.rb",
  "lib/rest-core/app/em-http-request.rb",
  "lib/rest-core/app/rest-client.rb",
  "lib/rest-core/builder.rb",
  "lib/rest-core/client.rb",
  "lib/rest-core/client/simple.rb",
  "lib/rest-core/client/universal.rb",
  "lib/rest-core/client_oauth1.rb",
  "lib/rest-core/error.rb",
  "lib/rest-core/event.rb",
  "lib/rest-core/middleware.rb",
  "lib/rest-core/middleware/auth_basic.rb",
  "lib/rest-core/middleware/bypass.rb",
  "lib/rest-core/middleware/cache.rb",
  "lib/rest-core/middleware/common_logger.rb",
  "lib/rest-core/middleware/default_headers.rb",
  "lib/rest-core/middleware/default_payload.rb",
  "lib/rest-core/middleware/default_query.rb",
  "lib/rest-core/middleware/default_site.rb",
  "lib/rest-core/middleware/defaults.rb",
  "lib/rest-core/middleware/error_detector.rb",
  "lib/rest-core/middleware/error_detector_http.rb",
  "lib/rest-core/middleware/error_handler.rb",
  "lib/rest-core/middleware/follow_redirect.rb",
  "lib/rest-core/middleware/json_decode.rb",
  "lib/rest-core/middleware/json_request.rb",
  "lib/rest-core/middleware/oauth1_header.rb",
  "lib/rest-core/middleware/oauth2_header.rb",
  "lib/rest-core/middleware/oauth2_query.rb",
  "lib/rest-core/middleware/timeout.rb",
  "lib/rest-core/middleware/timeout/eventmachine_timer.rb",
  "lib/rest-core/patch/multi_json.rb",
  "lib/rest-core/patch/rest-client.rb",
  "lib/rest-core/test.rb",
  "lib/rest-core/util/hmac.rb",
  "lib/rest-core/util/parse_query.rb",
  "lib/rest-core/version.rb",
  "lib/rest-core/wrapper.rb",
  "pending/test_multi.rb",
  "pending/test_test_util.rb",
  "rest-core.gemspec",
  "test/test_auth_basic.rb",
  "test/test_builder.rb",
  "test/test_cache.rb",
  "test/test_client.rb",
  "test/test_client_oauth1.rb",
  "test/test_default_query.rb",
  "test/test_error_detector.rb",
  "test/test_error_detector_http.rb",
  "test/test_follow_redirect.rb",
  "test/test_json_decode.rb",
  "test/test_json_request.rb",
  "test/test_oauth1_header.rb",
  "test/test_payload.rb",
  "test/test_timeout.rb",
  "test/test_universal.rb",
  "test/test_wrapper.rb"]
  s.homepage = "https://github.com/cardinalblue/rest-core"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Modular Ruby clients interface for REST APIs"
  s.test_files = [
  "test/test_auth_basic.rb",
  "test/test_builder.rb",
  "test/test_cache.rb",
  "test/test_client.rb",
  "test/test_client_oauth1.rb",
  "test/test_default_query.rb",
  "test/test_error_detector.rb",
  "test/test_error_detector_http.rb",
  "test/test_follow_redirect.rb",
  "test/test_json_decode.rb",
  "test/test_json_request.rb",
  "test/test_oauth1_header.rb",
  "test/test_payload.rb",
  "test/test_timeout.rb",
  "test/test_universal.rb",
  "test/test_wrapper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<multi_json>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
  end
end
