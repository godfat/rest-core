# rest-core [![Build Status](https://secure.travis-ci.org/godfat/rest-core.png?branch=master)](http://travis-ci.org/godfat/rest-core)

by Cardinal Blue <http://cardinalblue.com>

Lin Jen-Shin ([godfat][]) had given a talk about rest-core on
[RubyConf Taiwan 2011][talk]. The slide is in English, but the
talk is in Mandarin.

You can also read some other topics at [doc](https://github.com/cardinalblue/rest-core/blob/master/doc/ToC.md).

[godfat]: https://github.com/godfat
[talk]: http://rubyconf.tw/2011/#6

## LINKS:

* [github](https://github.com/cardinalblue/rest-core)
* [rubygems](https://rubygems.org/gems/rest-core)
* [rdoc](http://rdoc.info/projects/cardinalblue/rest-core)
* [mailing list](http://groups.google.com/group/rest-core/topics)

## DESCRIPTION:

Modular Ruby clients interface for REST APIs

There has been an explosion in the number of REST APIs available today.
To address the need for a way to access these APIs easily and elegantly,
we have developed [rest-core][], which consists of composable middleware
that allows you to build a REST client for any REST API. Or in the case of
common APIs such as Facebook, Github, and Twitter, you can simply use the
dedicated clients provided by [rest-more][].

[rest-core]: https://github.com/cardinalblue/rest-core
[rest-more]: https://github.com/cardinalblue/rest-more

## FEATURES:

* Modular interface for REST clients similar to WSGI/Rack for servers.
* Asynchronous/Synchronous styles with or without fibers are both supported.

## REQUIREMENTS:

### Mandatory:

* MRI (official CRuby) 1.8.7, 1.9.2, 1.9.3, Rubinius 1.8/1.9 and JRuby 1.8/1.9
* gem rest-client

### Optional:

* Fibers only work on Ruby 1.9+
* gem [em-http-request][] (if using eventmachine)
* gem [cool.io-http][] (if using cool.io)
* gem json or yajl-ruby (if using JsonDecode middleware)

[em-http-request]: https://github.com/igrigorik/em-http-request
[cool.io-http]: https://github.com/godfat/cool.io-http

## INSTALLATION:

    gem install rest-core

Or if you want development version, put this in Gemfile:

``` ruby
    gem 'rest-core', :git => 'git://github.com/cardinalblue/rest-core.git',
                     :submodules => true
```

If you just want to use Facebook or Twitter clients, please take a look at
[rest-more][] which has a lot of clients built with rest-core.

[rest-more]: http://github.com/cardinalblue/rest-more

## Build Your Own Clients:

You can use `RestCore::Builder` to build your own dedicated client:

``` ruby
    require 'rest-core'

    YourClient = RestCore::Builder.client do
      s = self.class # this is only for ruby 1.8!
      use s::DefaultSite , 'https://api.github.com/users/'
      use s::JsonDecode  , true
      use s::CommonLogger, method(:puts)
      use s::Cache       , nil, 3600
      run s::RestClient # the simplest and easier HTTP client
    end
```

And use it with per-instance basis (clients could have different
configuration, e.g. different cache time or timeout time):

``` ruby
    client = YourClient.new(:cache => {})
    client.get('cardinalblue') # cache miss
    client.get('cardinalblue') # cache hit

    client.site = 'http://github.com/api/v2/json/user/show/'
    client.get('cardinalblue') # cache miss
    client.get('cardinalblue') # cache hit
```

Runnable example is here: [example/rest-client.rb][]. Please see [rest-more][]
for more complex examples, and [slides][] from [rubyconf.tw/2011][rubyconf.tw]
for concepts.

[example/rest-client.rb]: https://github.com/cardinalblue/rest-core/blob/master/example/rest-client.rb
[rest-more]: https://github.com/cardinalblue/rest-more
[slides]: http://www.godfat.org/slide/2011-08-27-rest-core.html
[rubyconf.tw]: http://rubyconf.tw/2011/#6

## Asynchronous HTTP Requests:

I/O bound operations shouldn't be blocking the CPU! If you have a reactor,
i.e. event loop, you should take the advantage of that to make HTTP requests
non-blocking the whole process/thread. For now, we support eventmachine and
cool.io. Below is an example for eventmachine:

``` ruby
    require 'rest-core'

    AsynchronousClient = RestCore::Builder.client do
      s = self.class # this is only for ruby 1.8!
      use s::DefaultSite , 'https://api.github.com/users/'
      use s::JsonDecode  , true
      use s::CommonLogger, method(:puts)
      use s::Cache       , nil, 3600
      run s::EmHttpRequest
    end
```

If you're passing a block, the block is called after the response is
available. That is the block is the callback for the request.

``` ruby
    client = AsynchronousClient.new(:cache => {})
    EM.run{
      client.get('cardinalblue'){ |response|
        p response
        EM.stop
      }
    }
```

Otherwise, if you don't pass a block as the callback, EmHttpRequest (i.e.
the HTTP client for eventmachine) would call `Fiber.yield` to yield to the
original fiber, making asynchronous HTTP requests look like synchronous.
If you don't understand what does this mean, you can take a look at
[em-synchrony][]. It's basically the same idea.

``` ruby
    EM.run{
      Fiber.new{
        p client.get('cardinalblue')
        EM.stop
      }.resume
    }
```

[em-synchrony]: https://github.com/igrigorik/em-synchrony

Runnable example is here: [example/eventmachine.rb][].
You can also make multi-requests synchronously like this:

``` ruby
    EM.run{
      Fiber.new{
        fiber = Fiber.current
        result = {}
        client.get('cardinalblue'){ |response|
          result[0] = response
          fiber.resume(result) if result.size == 2
        }
        client.get('cardinalblue'){ |response|
          result[1] = response
          fiber.resume(result) if result.size == 2
        }
        p Fiber.yield
        EM.stop
      }.resume
    }
```

Runnable example is here: [example/multi.rb][].

[example/eventmachine.rb]: https://github.com/cardinalblue/rest-core/blob/master/example/eventmachine.rb
[example/multi.rb]: https://github.com/cardinalblue/rest-core/blob/master/example/multi.rb

## Supported HTTP clients:

* `RestCore::RestClient` (gem rest-client)
* `RestCore::EmHttpRequest` (gem em-http-request)
* `RestCore::Coolio` (gem cool.io)
* `RestCore::Auto` (which would pick one of the above depending on the
  context)

## Build Your Own Middlewares:

To be added.

## Build Your Own HTTP clients:

To be added.

## rest-core users:

* [topcoder](https://github.com/miaout17/topcoder)
* [s2sync](https://github.com/brucehsu/s2sync)
* [s2sync_web](https://github.com/brucehsu/s2sync_web)

## Powered sites:

* [PicCollage](http://pic-collage.com/)

## CHANGES:

* [CHANGES](https://github.com/cardinalblue/rest-core/blob/master/CHANGES.md)

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

* `env[RestCore::DRY]` is a boolean (either `true` or `false` or `nil`) which
  indicates that if we're only asking for modified `env`, instead of making
  real requests. It's used to ask for the real request URI, etc.

* `env[RestCore::FAIL]` is an array which contains failing events. Events
  could be any objects, it's handled by `RestCore::ErrorDetector` or any
  other custom _middleware_.

* `env[RestCore::LOG]` is an array which contains logging events. Events
  could be any objects, it's handled by `RestCore::CommonLogger` or
  any other custom _middleware_.

## CONTRIBUTORS:

* Andrew Liu (@eggegg)
* andy (@coopsite)
* Barnabas Debreczeni (@keo)
* Bruce Chu (@bruchu)
* Ethan Czahor (@ethanz5)
* Florent Vaucelle (@florent)
* Jaime Cham (@jcham)
* John Fan (@johnfan)
* Lin Jen-Shin (@godfat)
* Mariusz Pruszynski (@snicky)
* Mr. Big Cat (@miaout17)
* Nicolas Fouché (@nfo)

## LICENSE:

Apache License 2.0

Copyright (c) 2011-2012, Cardinal Blue

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
