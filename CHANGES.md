# rest-core CHANGES

## rest-core 0.3.0 -- ?

* [facebook] RestGraph is Facebook now.
* [facebook] Facebook::RailsUtil is imported from [rest-graph][]
* [facebook] Use json_decode instead of auto_decode as rest-graph
* [twitter] Fixed opts in Twitter#tweet
* [rest-core] We no longer explicitly depends on Rack
* [rest-core] Added a shorthand RC to access RestCore
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
