# rest-core [![Build Status](http://travis-ci.org/godfat/rest-core.png)](http://travis-ci.org/godfat/rest-core)

by Cardinal Blue <http://cardinalblue.com>

## LINKS:

* [github](https://github.com/cardinalblue/rest-core)
* [rubygems](http://rubygems.org/gems/rest-core)
* [rdoc](http://rdoc.info/projects/cardinalblue/rest-core)
* [mailing list](http://groups.google.com/group/rest-core/topics)

## DESCRIPTION:

A modular Ruby REST client collection/infrastructure

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
[rest-graph]: http://github.com/cardinalblue/rest-graph

## REQUIREMENTS:

* Tested with MRI (official CRuby) 1.8.7, 1.9.2, 1.9.3, Rubinius and JRuby
* gem rest-client (for now)

## INSTALLATION:

    gem install rest-core

Or if you want development version, put this in Gemfile:

    gem 'rest-core', :git => 'git://github.com/cardinalblue/rest-core.git',
                     :submodules => true

## Built-in Clients Example:

    require 'rest-core'

    RestCore::Twitter.new.statuses('_cardinalblue') # get user tweets
    RestCore::Github.new.get('users/cardinalblue')  # get user info

    linkedin = RestCore::Linkedin.new(:consumer_key    => '...',
                                      :consumer_secret => '...')
    linkedin.authorize_url!   # copy and paste the URL in browser to authorize
    linkedin.authorize!('..') # paste your code from browser
    linkedin.me               # get current user info

    RestCore::Facebook.new.get('4') # get user info

See [example][] for more complex examples.

[example]: https://github.com/cardinalblue/rest-core/tree/master/example

## Build Your Own Clients Example:

    require 'rest-core'

    YourClient = RestCore::Builder.client do
      s = self.class # this is only for ruby 1.8!
      use s::DefaultSite , 'https://api.github.com/users/'
      use s::JsonDecode  , true
      use s::CommonLogger, method(:puts)
      use s::Cache       , {}, 3600
      run s::RestClient
    end

    client = YourClient.new
    client.get('cardinalblue') # cache miss
    client.get('cardinalblue') # cache hit

    client.site = 'http://github.com/api/v2/json/user/show/'
    client.get('cardinalblue') # cache miss
    client.get('cardinalblue') # cache hit

See [built-in clients][] for more complex examples.

[built-in clients]: https://github.com/cardinalblue/rest-core/tree/master/lib/rest-core/client

## GLOSSARY:

* A _client_ is a class which can new connections to make requests.
  For instance, `RestCore::Facebook.new.get('4')`

* An _app_ is an HTTP client which would do the underneath HTTP requests.
  For instance, `RestCore::RestClient` is an HTTP client which uses
  rest-client gem (`::RestClient`) to make HTTP requests.

* A _middleware_ is a component for a rest-core stack.
  For instance, `RestCore::DefaultSite` is a middleware which would add
  default site URL in front of the request URI if it is not started with
  http://, thus you can do this: `RestCore::Facebook.get('4')` without
  specifying where the site (Facebook) it is.

* `RestCore::Wrapper` is a utility which could help you wrap a number of
  middlewares into another middleware. Currently, it's used in
  `RestCore::Buidler` and `RestCore::Cache`.

* `RestCore::Builder` is a utility which could help you build a _client_
  with a collection of _middlewares_ and an _app_. i.e. a rest-core stack.

* `RestCore::Middleware` is a utility which could help you build a non-trivial
  middleware. More explanation to come...

* `RestCore::Client` is a module which would be included in a generated
  _client_ by `RestCore::Builder`. It contains a number of convenient
  functions which is generally useful.

* `RestCore::ClientOAuth1` is a module which should be included in a OAuth1.0
  client. It contains a number of convenient functions which is useful for an
  OAuth 1.0 client.

* An `env` is a hash which contains all the information for both request and
  response. It's mostly seen in `@app.call(env)` See other explanation
  such as `env[RestCore::REQUEST_METHOD]` for more detail.

* `env[RestCore::REQUEST_METHOD]` is a symbol representing which HTTP method
  would be used in the subsequent HTTP request. The possible values are
  either: `:get`, `:post`, `:put` or `:delete`.

* `env[RestCore::REQUEST_PATH]` is a string representing which HTTP path
  would be used in the subsequent HTTP request. This path could also include
  the protocol, not only the path. e.g. `"http://graph.facebook.com/4"` or
  simply `"4"`. In the case of built-in Facebook client, the
  `RestCore::DefaultSite` middleware would take care of the site.

* `env[RestCore::REQUEST_QUERY]` is a hash which keys are query keys and
  values are query values. Both keys and values' type should be String, not
  Symbol. Values with nil or false would be ignored. Both keys and values
  would be escaped automatically.

* `env[RestCore::REQUEST_PAYLOAD]` is a hash which keys are payload keys and
  values are payload values. Both keys and values' type should be String,
  not Symbol. Values with nil or false would be ignored. Both keys and values
  would be escaped automatically.

* `env[RestCore::REQUEST_HEADERS]` is a hash which keys are header names and
  values are header values. Both keys and values' type should be String,
  not Symbol. Values with nil or false would be ignored.

* `env[RestCore::RESPONSE_BODY]` is a string which is returned by the server.
  Might be nil if there's no response or not yet making HTTP request.

* `env[RestCore::RESPONSE_STATUS]` is a number which is returned by the
  server for the HTTP status. Might be nil if there's no response or not
  yet making HTTP request.

* `env[RestCore::RESPONSE_HEADERS]` is a hash which is returned by the server
  for the response headers. Both keys and values' type should be String.

* `env[RestCore::ASK]` is a boolean (either `true` or `false` or `nil`) which
  indicate that if we're only asking for the modified `env`, instead of making
  real requests. It's used to ask for the real request URI, etc.

* `env[RestCore::FAIL]` is an array which contains failing events. Events
  could be any objects, it's handled by `RestCore::ErrorDetector` or any
  other custom _middleware_.

* `env[RestCore::LOG]` is an array which contains logging events. Events
  could be any objects, it's handled by `RestCore::CommonLogger` or
  any other custom _middleware_.

## LICENSE:

  Apache License 2.0

  Copyright (c) 2011, Cardinal Blue

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     <http://www.apache.org/licenses/LICENSE-2.0>

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
