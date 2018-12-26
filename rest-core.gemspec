# -*- encoding: utf-8 -*-
# stub: rest-core 4.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rest-core".freeze
  s.version = "4.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Lin Jen-Shin (godfat)".freeze]
  s.date = "2018-12-26"
  s.description = "Various [rest-builder](https://github.com/godfat/rest-builder) middleware\nfor building REST clients.\n\nCheckout [rest-more](https://github.com/godfat/rest-more) for pre-built\nclients.".freeze
  s.email = ["godfat (XD) godfat.org".freeze]
  s.files = [
  ".gitignore".freeze,
  ".gitmodules".freeze,
  ".travis.yml".freeze,
  "CHANGES.md".freeze,
  "Gemfile".freeze,
  "LICENSE".freeze,
  "NOTE.md".freeze,
  "README.md".freeze,
  "Rakefile".freeze,
  "TODO.md".freeze,
  "example/simple.rb".freeze,
  "example/use-cases.rb".freeze,
  "lib/rest-core.rb".freeze,
  "lib/rest-core/client/universal.rb".freeze,
  "lib/rest-core/client_oauth1.rb".freeze,
  "lib/rest-core/event.rb".freeze,
  "lib/rest-core/middleware/auth_basic.rb".freeze,
  "lib/rest-core/middleware/bypass.rb".freeze,
  "lib/rest-core/middleware/cache.rb".freeze,
  "lib/rest-core/middleware/clash_response.rb".freeze,
  "lib/rest-core/middleware/common_logger.rb".freeze,
  "lib/rest-core/middleware/default_headers.rb".freeze,
  "lib/rest-core/middleware/default_payload.rb".freeze,
  "lib/rest-core/middleware/default_query.rb".freeze,
  "lib/rest-core/middleware/default_site.rb".freeze,
  "lib/rest-core/middleware/defaults.rb".freeze,
  "lib/rest-core/middleware/error_detector.rb".freeze,
  "lib/rest-core/middleware/error_detector_http.rb".freeze,
  "lib/rest-core/middleware/error_handler.rb".freeze,
  "lib/rest-core/middleware/follow_redirect.rb".freeze,
  "lib/rest-core/middleware/json_request.rb".freeze,
  "lib/rest-core/middleware/json_response.rb".freeze,
  "lib/rest-core/middleware/oauth1_header.rb".freeze,
  "lib/rest-core/middleware/oauth2_header.rb".freeze,
  "lib/rest-core/middleware/oauth2_query.rb".freeze,
  "lib/rest-core/middleware/query_response.rb".freeze,
  "lib/rest-core/middleware/retry.rb".freeze,
  "lib/rest-core/middleware/smash_response.rb".freeze,
  "lib/rest-core/middleware/timeout.rb".freeze,
  "lib/rest-core/test.rb".freeze,
  "lib/rest-core/util/clash.rb".freeze,
  "lib/rest-core/util/config.rb".freeze,
  "lib/rest-core/util/dalli_extension.rb".freeze,
  "lib/rest-core/util/hmac.rb".freeze,
  "lib/rest-core/util/json.rb".freeze,
  "lib/rest-core/util/parse_link.rb".freeze,
  "lib/rest-core/util/parse_query.rb".freeze,
  "lib/rest-core/util/smash.rb".freeze,
  "lib/rest-core/version.rb".freeze,
  "rest-core.gemspec".freeze,
  "task/README.md".freeze,
  "task/gemgem.rb".freeze,
  "test/config/rest-core.yaml".freeze,
  "test/test_auth_basic.rb".freeze,
  "test/test_cache.rb".freeze,
  "test/test_clash.rb".freeze,
  "test/test_clash_response.rb".freeze,
  "test/test_client_oauth1.rb".freeze,
  "test/test_config.rb".freeze,
  "test/test_dalli_extension.rb".freeze,
  "test/test_default_headers.rb".freeze,
  "test/test_default_payload.rb".freeze,
  "test/test_default_query.rb".freeze,
  "test/test_default_site.rb".freeze,
  "test/test_error_detector.rb".freeze,
  "test/test_error_detector_http.rb".freeze,
  "test/test_error_handler.rb".freeze,
  "test/test_follow_redirect.rb".freeze,
  "test/test_json_request.rb".freeze,
  "test/test_json_response.rb".freeze,
  "test/test_oauth1_header.rb".freeze,
  "test/test_oauth2_header.rb".freeze,
  "test/test_parse_link.rb".freeze,
  "test/test_query_response.rb".freeze,
  "test/test_retry.rb".freeze,
  "test/test_smash.rb".freeze,
  "test/test_smash_response.rb".freeze,
  "test/test_timeout.rb".freeze,
  "test/test_universal.rb".freeze]
  s.homepage = "https://github.com/godfat/rest-core".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "3.0.1".freeze
  s.summary = "Various [rest-builder](https://github.com/godfat/rest-builder) middleware".freeze
  s.test_files = [
  "test/test_auth_basic.rb".freeze,
  "test/test_cache.rb".freeze,
  "test/test_clash.rb".freeze,
  "test/test_clash_response.rb".freeze,
  "test/test_client_oauth1.rb".freeze,
  "test/test_config.rb".freeze,
  "test/test_dalli_extension.rb".freeze,
  "test/test_default_headers.rb".freeze,
  "test/test_default_payload.rb".freeze,
  "test/test_default_query.rb".freeze,
  "test/test_default_site.rb".freeze,
  "test/test_error_detector.rb".freeze,
  "test/test_error_detector_http.rb".freeze,
  "test/test_error_handler.rb".freeze,
  "test/test_follow_redirect.rb".freeze,
  "test/test_json_request.rb".freeze,
  "test/test_json_response.rb".freeze,
  "test/test_oauth1_header.rb".freeze,
  "test/test_oauth2_header.rb".freeze,
  "test/test_parse_link.rb".freeze,
  "test/test_query_response.rb".freeze,
  "test/test_retry.rb".freeze,
  "test/test_smash.rb".freeze,
  "test/test_smash_response.rb".freeze,
  "test/test_timeout.rb".freeze,
  "test/test_universal.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-builder>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rest-builder>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-builder>.freeze, [">= 0"])
  end
end
