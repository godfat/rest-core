# rest-core CHANGES

## rest-core 0.7.0 --

From now on, prebuilt clients such as `RC::Facebook`, `RC::Twitter` and
others are moved to [rest-more][]

[rest-more]: https://github.com/cardinalblue/rest-more

## rest-core 0.4.0 -- 2011-09-26

### Incompatible changes:

* [dry] Now `RestCore::Ask` is renamed to `RestCore::Dry` for better
  understanding. Thanks miaout17

* [client] Now `request` method takes an env and an app to make requests,
  instead of a weird requests array.

* [client] Now if you really want to disable something, for example,
  disabling cache when the default cache is `Rails.cache`, you'll need to
  pass `false` instead of `nil`. This is because `nil` stands for using
  defaults in rest-core.

* [client] Defaults priorities are changed to:
  per-request > instance variable > class defaults > middleware defaults
  See *test_client.rb* for more detailed definition. If you don't understand
  this, don't worry, since then this won't affect you.

### Compatible changes:

* [client] Introduced a new method `request_full` which is exactly the same
  as `request` but also returns various information from the app, including
  `RESPONSE_STATUS` and `RESPONSE_HEADERS`

* [client] Removed various unused, untested, undocumented legacy from
  rest-graph.

* [error] Introduced `RestCore::Error` which is the base class for all
  exceptions raised by rest-core

* [builder] Now `RestCore::Builder.default_app` is the default app which
  would be used for building clients without setting an app. By default,
  it's `RestClient`, but you can change it if you like.

* [builder] It no longer builds a @wrapped app. If you don't understand this,
  then this does nothing for you. It's an internal change. (or bug fix)

* [wrapper] Now `RestCore::Wrapper.default_app` is the default app which
  would be used for wrapping middlewares without setting an app. By default,
  it's `Dry`, but you can change it if you like.

* [wrapped] Fixed a bug that force middlewares to implement `members` method,
  which should be optional. Thanks miaout17

* [facebook][rails_util] Now default cache is `Rails.cache` instead of nil
* [simple]   Added a Simple client, which only wraps RestClient
* [univeral] Added an Universal client, which could be used for anything
* [flurry]   Added a Flurry client, along with its `Flurry::RailsUtil`
* [mixi]     Added a Mixi client

* [bypass] Added a Bypass middleware which does nothing but passing env
* [oauth2_header] OAuth2Header is a middleware which would pass access_token
  in header instead of in query string.
* [common_logger] nil object would no longer be logged
* [json_decode] Do nothing if we are being asked for env (dry mode)
* [cache] Now default `:expires_in` is 600 down from 3600
* [middleware] Now not only query values would be escaped, but also keys.

* [rib-rest-core] Introduced an interactive shell. You'll need [rib][] to
  run this: `rib rest-core`. It is using an universal client to access
  arbitrary websites.

[rib]: https://github.com/godfat/rib

## rest-core 0.3.0 -- 2011-09-03

* [facebook] RestGraph is Facebook now.
* [facebook] Facebook::RailsUtil is imported from [rest-graph][]
* [facebook] Use json_decode instead of auto_decode as rest-graph
* [facebook] No longer calls URI.encode on Facebook broken URL
* [twitter] Fixed opts in Twitter#tweet
* [twitter] Introduced Twitter::Error instead of RuntimeError!
* [twitter] By default log nothing
* [rest-core] We no longer explicitly depends on Rack
* [rest-core] Added a shorthand RC to access RestCore
* [rest-core] Eliminated a lot of warnings
* [cache] All clients no longer have default hash cache
* [oauth2_query] Now we always use the term "access_token"
* [config] Now Config#load and Config#load_for_rails take namespace
  e.g. rest-core.yaml:

      development:
        facebook:
          app_id: 123
        twitter:
          consumer_key: abc

[rest-graph]: https://github.com/cardinalblue/rest-graph

## rest-core 0.2.3 -- 2011-08-27

* Adding rack as a runtime dependency for now.
  To reduce frustration for new comer...

## rest-core 0.2.2 -- 2011-08-26

* Adding rest-client as a runtime dependency for now.
  In the future, it should be taken out because of multiple
  selectable HTTP client backend (rest-core app).

## rest-core 0.2.1 -- 2011-08-25

* [twitter] Fixed default site
* [twitter] Now Twitter#tweet accepts a 2nd argument to upload an image
* [oauth1_header] Fixed a bug for multipart posting. Since Rails' uploaded
                  file is not an IO object, so we can't only test against
                  IO object, but also read method.

## rest-core 0.2.0 -- 2011-08-24

* First serious release!
