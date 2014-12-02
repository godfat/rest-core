# rest-core [![Build Status](https://secure.travis-ci.org/godfat/rest-core.png?branch=master)](http://travis-ci.org/godfat/rest-core) [![Coverage Status](https://coveralls.io/repos/godfat/rest-core/badge.png)](https://coveralls.io/r/godfat/rest-core)

by Lin Jen-Shin ([godfat](http://godfat.org))

Lin Jen-Shin ([godfat][]) had given a talk about rest-core on
[RubyConf Taiwan 2011][talk]. The slide is in English, but the
talk is in Mandarin.

[godfat]: https://github.com/godfat
[talk]: http://rubyconf.tw/2011/#6

## LINKS:

* [github](https://github.com/godfat/rest-core)
* [rubygems](https://rubygems.org/gems/rest-core)
* [rdoc](http://rdoc.info/projects/godfat/rest-core)
* [mailing list](http://www.freelists.org/list/rest-core)
  Send your questions to: <rest-core@freelists.org> and you could read
  through [archives](http://www.freelists.org/archives/rest-core)

## DESCRIPTION:

Modular Ruby clients interface for REST APIs.

There has been an explosion in the number of REST APIs available today.
To address the need for a way to access these APIs easily and elegantly,
we have developed rest-core, which consists of composable middleware
that allows you to build a REST client for any REST API. Or in the case of
common APIs such as Facebook, Github, and Twitter, you can simply use the
dedicated clients provided by [rest-more][].

[rest-more]: https://github.com/godfat/rest-more

## FEATURES:

* Modular interface for REST clients similar to WSGI/Rack for servers.
* Concurrent requests with synchronous or asynchronous interfaces with
  threads.

## WHY?

Build your own API clients for less dependencies, less codes,
less memory, less conflicts, and run faster.

## REQUIREMENTS:

### Mandatory:

* Tested with MRI (official CRuby), Rubinius and JRuby.
* gem [httpclient][]
* gem [mime-types][]
* gem [timers][]

[httpclient]: https://github.com/nahi/httpclient
[mime-types]: https://github.com/halostatue/mime-types
[timers]: https://github.com/celluloid/timers

### Optional:

* gem json or yajl-ruby, or multi_json (if `JsonResponse` or
  `JsonRequest` middleware is used)

## INSTALLATION:

``` shell
gem install rest-core
```

Or if you want development version, put this in Gemfile:

``` ruby
gem 'rest-core', :git => 'git://github.com/godfat/rest-core.git',
                 :submodules => true
```

If you just want to use Facebook or Twitter clients, please take a look at
[rest-more][] which has a lot of clients built with rest-core.

## Build Your Own Clients:

You can use `RestCore::Builder` to build your own dedicated clients.
Note that `RC` is an alias of `RestCore`

``` ruby
require 'rest-core'
YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonResponse, true
  use RC::CommonLogger, method(:puts)
  use RC::Cache       , nil, 3600 # :expires_in if cache store supports
end
```

### Basic Usage:

And use it with per-instance basis (clients could have different
configuration, e.g. different cache time or timeout time):

``` ruby
client = YourClient.new(:cache => {})
client.get('godfat') # cache miss
client.get('godfat') # cache hit

client.site = 'http://github.com/api/v2/json/user/show/'
client.get('godfat') # cache miss
client.get('godfat') # cache hit
```

### Concurrent Requests with Futures:

You can also make concurrent requests easily:
(see "Advanced Concurrent HTTP Requests -- Embrace the Future" for detail)

``` ruby
a = [client.get('godfat'), client.get('cardinalblue')]
puts "It's not blocking... but doing concurrent requests underneath"
p a.map{ |r| r['name'] } # here we want the values, so it blocks here
puts "DONE"
```

### Exception Handling for Futures:

Note that since the API call would only block whenever you're looking at
the response, it won't raise any exception at the time the API was called.
So if you want to block and handle the exception at the time API was called,
you would do something like this:

``` ruby
begin
  response = client.get('bad-user').tap{} # .tap{} is the point
  do_the_work(response)
rescue => e
  puts "Got an exception: #{e}"
end
```

The trick here is forcing the future immediately give you the exact response,
so that rest-core could see the response and raise the exception. You can
call whatever methods on the future to force this behaviour, but since `tap{}`
is a method from `Kernel` (which is included in `Object`), it's always
available and would return the original value, so it is the easiest method
to be remembered and used.

If you know the response must be a string, then you can also use `to_s`.
Like this:

``` ruby
begin
  response = client.get('bad-user').to_s
  do_the_work(response)
rescue => e
  puts "Got an exception: #{e}"
end
```

Or you can also do this:

``` ruby
begin
  response = client.get('bad-user')
  response.class # simply force it to load
  do_the_work(response)
rescue => e
  puts "Got an exception: #{e}"
end
```

The point is simply making a method call to force it load, whatever method
should work.

### Concurrent Requests with Callbacks:

On the other hand, callback mode also available:

``` ruby
client.get('godfat'){ |v| p v }
puts "It's not blocking... but doing concurrent requests underneath"
client.wait # we block here to wait for the request done
puts "DONE"
```

### Exception Handling for Callbacks:

What about exception handling in callback mode? You know that we cannot
raise any exception in the case of using a callback. So rest-core would
pass the exception object into your callback. You can handle the exception
like this:

``` ruby
client.get('bad-user') do |response|
  if response.kind_of?(Exception)
    puts "Got an exception: #{response}"
  else
    do_the_work(response)
  end
end
puts "It's not blocking... but doing concurrent requests underneath"
client.wait # we block here to wait for the request done
puts "DONE"
```

### Thread Pool / Connection Pool

Underneath, rest-core would spawn a thread for each request, freeing you
from blocking. However, occasionally we would not want this behaviour,
giving that we might have limited resource and cannot maximize performance.

For example, maybe we could not afford so many threads running concurrently,
or the target server cannot accept so many concurrent connections. In those
cases, we would want to have limited concurrent threads or connections.

``` ruby
YourClient.pool_size = 10
YourClient.pool_idle_time = 60
```

This could set the thread pool size to 10, having a maximum of 10 threads
running together, growing from requests. Each threads idled more than 60
seconds would be shut down automatically.

Note that `pool_size` should at least be larger than 4, or it might be
very likely to have _deadlock_ if you're using nested callbacks and having
a large number of concurrent calls.

Also, setting `pool_size` to `-1` would mean we want to make blocking
requests, without spawning any threads. This might be useful for debugging.

### Gracefully shutdown

To shutdown gracefully, consider shutdown the thread pool (if we're using it),
and wait for all requests for a given client. For example, suppose we're using
`RC::Universal`, we'll do this when we're shutting down:

``` ruby
RC::Universal.shutdown
```

We could put them in `at_exit` callback like this:

``` ruby
at_exit do
  RC::Universal.shutdown
end
```

If you're using unicorn, you probably want to put that in the config.

### Persistent connections (keep-alive connections)

Since we're using [httpclient][] by default now, we would reuse connections,
making it much faster for hitting the same host repeatedly.

### Streaming Requests

Suppose we want to POST a file, instead of trying to read all the contents
in memory and send them, we could stream it from the file system directly.

``` ruby
client.post('path', File.open('README.md'))
```

Basically, payloads could be any IO object. Check out
[RC::Payload](lib/rest-core/util/payload.rb) for more information.

### Streaming Responses

This one is much harder then streaming requests, since all built-in
middleware actually assume the responses should be blocking and buffered.
Say, some JSON parser could not really parse from streams.

We solve this issue similarly to the way Rack solves it. That is, we hijack
the socket. This would be how we're doing:

``` ruby
sock = client.get('path', {}, RC::HIJACK => true)
p sock.read(10)
p sock.read(10)
p sock.read(10)
```

Of course, if we don't want to block in order to get the socket, we could
always use the callback form:

``` ruby
client.get('path', {}, RC::HIJACK => true) do |sock|
  p sock.read(10)
  p sock.read(10)
  p sock.read(10)
end
```

Note that since the socket would be put inside `RC::RESPONSE_SOCKET`
instead of `RC::RESPONSE_BODY`, not all middleware would handle the socket.
In the case of hijacking, `RC::RESPONSE_BODY` would always be mapped to an
empty string, as it does not make sense to store the response in this case.

### SSE (Server-Sent Events)

Not only JavaScript could receive server-sent events, any languages could.
Doing so would establish a keep-alive connection to the server, and receive
data periodically. We'll take Firebase as an example:

If you are using Firebase, please consider the pre-built client in
[rest-more][] instead.

``` ruby
require 'rest-core'

# Streaming over 'users/tom.json'
cl = RC::Universal.new(:site => 'https://SampleChat.firebaseIO-demo.com/')
es = cl.event_source('users/tom.json', {}, # this is query, none here
                     :headers => {'Accept' => 'text/event-stream'})

@reconnect = true

es.onopen   { |sock| p sock } # Called when connected
es.onmessage{ |event, data, sock| p event, data } # Called for each message
es.onerror  { |error, sock| p error } # Called whenever there's an error
# Extra: If we return true in onreconnect callback, it would automatically
#        reconnect the node for us if disconnected.
es.onreconnect{ |error, sock| p error; @reconnect }

# Start making the request
es.start

# Try to close the connection and see it reconnects automatically
es.close

# Update users/tom.json
p cl.put('users/tom.json', RC::Json.encode(:some => 'data'))
p cl.post('users/tom.json', RC::Json.encode(:some => 'other'))
p cl.get('users/tom.json')
p cl.delete('users/tom.json')

# Need to tell onreconnect stops reconnecting, or even if we close
# the connection manually, it would still try to reconnect again.
@reconnect = false

# Close the connection to gracefully shut it down.
es.close
```

Those callbacks would be called in a separate background thread,
so we don't have to worry about blocking it. If we want to wait for
the connection to be closed, we could call `wait`:

``` ruby
es.wait # This would block until the connection is closed
```

### More Control with `request_full`:

You can also use `request_full` to retrieve everything including response
status, response headers, and also other rest-core options. But since using
this interface is like using Rack directly, you have to build the env
manually. To help you build the env manually, everything has a default,
including the path.

``` ruby
client.request_full({})[RC::RESPONSE_BODY] # {"message"=>"Not Found"}
# This would print something like this:
# RestCore: spent 1.135713 Requested GET https://api.github.com/users/

client.request_full(RC::REQUEST_PATH => 'godfat')[RC::RESPONSE_STATUS]
client.request_full(RC::REQUEST_PATH => 'godfat')[RC::RESPONSE_HEADERS]
# Headers are normalized with all upper cases and
# dashes are replaced by underscores.

# To make POST (or any other request methods) request:
client.request_full(RC::REQUEST_PATH   => 'godfat',
                    RC::REQUEST_METHOD => :post)[RC::RESPONSE_STATUS] # 404
```

### Examples:

Runnable example is at: [example/simple.rb][]. Please see [rest-more][]
for more complex examples to build clients, and [slides][] from
[rubyconf.tw/2011][talk] for concepts.

[example/simple.rb]: example/simple.rb
[slides]: http://www.godfat.org/slide/2011-08-27-rest-core.html

## Playing Around:

You can also play around with `RC::Universal` client, which has installed
_all_ reasonable middleware built-in rest-core. So the above example could
also be achieved by:

``` ruby
require 'rest-core'
client = RC::Universal.new(:site          => 'https://api.github.com/users/',
                           :json_response => true,
                           :log_method    => method(:puts))
client.get('godfat')
```

`RC::Universal` is defined as:

``` ruby
module RestCore
  Universal = Builder.client do
    use Timeout       , 0

    use DefaultSite   , nil
    use DefaultHeaders, {}
    use DefaultQuery  , {}
    use DefaultPayload, {}
    use JsonRequest   , false
    use AuthBasic     , nil, nil
    use CommonLogger  , method(:puts)
    use ErrorHandler  , nil
    use ErrorDetectorHttp

    use SmashResponse , false
    use ClashResponse , false
    use  JsonResponse , false
    use QueryResponse , false

    use Cache         , {}, 600 # default :expires_in 600 but the default
                                # cache {} didn't support it

    use FollowRedirect, 10
  end
end
```

If you have both [rib][] and [rest-more][] installed, you can also play
around with an interactive shell, like this:

``` shell
rib rest-core
```

And you will be entering a rib shell, which `self` is an instance of
`RC::Universal` you can play:

    rest-core>> get 'https://api.github.com/users/godfat'

will print out the response from Github. You can also do this to make
calling Github easier:

    rest-core>> self.site = 'https://api.github.com/users/'
    rest-core>> self.json_response = true

Then it would do exactly like the original example:

    rest-core>> get 'godfat' # you get a nice parsed hash

This is mostly for fun and experimenting, so it's only included in
[rest-more][] and [rib][]. Please make sure you have both of them
installed before trying this.

[rib]: https://github.com/godfat/rib

## List of built-in Middleware:

### [RC::AuthBasic][]

### [RC::Bypass][]

### [RC::Cache][]

    use RC::Cache, cache, expires_in

where `cache` is the cache store which the cache data would be storing to.
`expires_in` would be passed to
`cache.store(key, value :expires_in => expires_in)` if `store` method is
available and its arity should be at least 3. The interface to the cache
could be referenced from [moneta][], namely:

* (required) `[](key)`
* (required) `[]=(key, value)`
* (optional, required if :expires_in is needed) `store(key, value, options)`

Note that `{:expires_in => seconds}` would be passed as the options in
`store(key, value, options)`, and a plain old Ruby hash `{}` satisfies
the mandatory requirements: `[](key)` and `[]=(key, value)`, but not the
last one for `:expires_in` because the `store` method for Hash did not take
the third argument. That means we could use `{}` as the cache but it would
simply ignore `:expires_in`.

### [RC::CommonLogger][]

### [RC::DefaultHeaders][]

### [RC::DefaultPayload][]

### [RC::DefaultQuery][]

### [RC::DefaultSite][]

### [RC::Defaults][]

### [RC::ErrorDetector][]

### [RC::ErrorDetectorHttp][]

### [RC::ErrorHandler][]

### [RC::FollowRedirect][]

### [RC::JsonRequest][]

### [RC::JsonResponse][]

### [RC::Oauth1Header][]

### [RC::Oauth2Header][]

### [RC::Oauth2Query][]

### [RC::Timeout][]

[RC::AuthBasic]: lib/rest-core/middleware/auth_basic.rb
[RC::Bypass]: lib/rest-core/middleware/bypass.rb
[RC::Cache]: lib/rest-core/middleware/cache.rb
[RC::ClashResponse]: lib/rest-core/middleware/clash_response.rb
[RC::CommonLogger]: lib/rest-core/middleware/common_logger.rb
[RC::DefaultHeaders]: lib/rest-core/middleware/default_headers.rb
[RC::DefaultPayload]: lib/rest-core/middleware/default_payload.rb
[RC::DefaultQuery]: lib/rest-core/middleware/default_query.rb
[RC::DefaultSite]: lib/rest-core/middleware/default_site.rb
[RC::Defaults]: lib/rest-core/middleware/defaults.rb
[RC::ErrorDetector]: lib/rest-core/middleware/error_detector.rb
[RC::ErrorDetectorHttp]: lib/rest-core/middleware/error_detector_http.rb
[RC::ErrorHandler]: lib/rest-core/middleware/error_handler.rb
[RC::FollowRedirect]: lib/rest-core/middleware/follow_redirect.rb
[RC::JsonRequest]: lib/rest-core/middleware/json_request.rb
[RC::JsonResponse]: lib/rest-core/middleware/json_response.rb
[RC::Oauth1Header]: lib/rest-core/middleware/oauth1_header.rb
[RC::Oauth2Header]: lib/rest-core/middleware/oauth2_header.rb
[RC::Oauth2Query]: lib/rest-core/middleware/oauth2_query.rb
[RC::SmashResponse]: lib/rest-core/middleware/smash_response.rb
[RC::Retry]: lib/rest-core/middleware/retry.rb
[RC::Timeout]: lib/rest-core/middleware/timeout.rb
[moneta]: https://github.com/minad/moneta#expiration

## Build Your Own Middleware:

### How We Pick the Default Value:

There are a number of ways to specify a default value, each with different
priorities. Suppose we have a middleware which remembers an integer:

``` ruby
class HP
  def self.members; [:hp]; end
  include RC::Middleware
  def call env, &k
    puts "HP: #{hp(env)}"
    app.call(env, &k)
  end
end
Mage = RC::Builder.client do
  use HP, 5 # the very last default
end
mage = Mage.new
```

1. The one passed to the request directly gets the first priority, e.g.

``` ruby
mage.get('http://example.com/', {}, :hp => 1) # prints HP: 1
```

2. The one saved as an instance variable in the client gets the 2nd place.

``` ruby
mage.hp = 2
mage.get('http://example.com/')               # prints HP: 2
mage.get('http://example.com/', {}, :hp => 1) # prints HP: 1
mage.hp         # still 2
mage.hp = false # disable hp
mage.hp = nil   # reset to default
```

3. The method defined in the client instance named `default_hp` gets the 3rd.

``` ruby
class Mage
  def default_hp
    3
  end
end
mage.get('http://example.com/')               # prints HP: 3
mage.hp       # 3
mage.hp = nil # reset default
Mage.send(:remove_method, :default_hp)
```

4. The method defined in the client class named `default_hp` gets the 4rd.
   P.S. In [rest-more][], with `RestCore::Config` it would generate a
   `DefaultAttributes` module which defines this kind of default method and
   then is extended into the client class. You could still define this method
   to override the default though.

``` ruby
class Mage
  def self.default_hp
    4
  end
end
mage.get('http://example.com/')               # prints HP: 4
mage.hp       # 4
mage.hp = nil # reset to default
Mage.singleton_class.send(:remove_method, :default_hp)
```

5. The one defined in the middleware gets the last place.

``` ruby
mage.get('http://example.com/')               # prints HP: 5
mage.hp       # 5
mage.hp = nil # reset to default
```

You can find all the details in client.rb and middleware.rb. See the
included method hooks.

## Advanced Concurrent HTTP Requests -- Embrace the Future

### The Interface

There are a number of different ways to make concurrent requests in
rest-core. They could be roughly categorized to two different forms.
One is using the well known callbacks, while the other one is using
through a technique called [future][]. Basically, it means it would
return you a promise, which would eventually become the real value
(response here) you were asking for whenever you really want it.
Otherwise, the program keeps running until the value is evaluated,
and blocks there if the computation (response) hasn't been done yet.
If the computation is already done, then it would simply return you
the result.

Here's a very simple example for using futures:

``` ruby
require 'rest-core'
YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonResponse, true
  use RC::CommonLogger, method(:puts)
end

client = YourClient.new
puts "httpclient with threads doing concurrent requests"
a = [client.get('godfat'), client.get('cardinalblue')]
puts "It's not blocking... but doing concurrent requests underneath"
p a.map{ |r| r['name'] } # here we want the values, so it blocks here
puts "DONE"
```

And here's a corresponded version for using callbacks:

``` ruby
require 'rest-core'
YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonResponse, true
  use RC::CommonLogger, method(:puts)
end

client = YourClient.new
puts "httpclient with threads doing concurrent requests"
client.get('godfat'){ |v|
         p v['name']
       }.
       get('cardinalblue'){ |v|
         p v['name']
       }
puts "It's not blocking... but doing concurrent requests underneath"
client.wait # until all requests are done
puts "DONE"
```

You can pick whatever works for you.

[future]: http://en.wikipedia.org/wiki/Futures_and_promises

A full runnable example is at: [example/simple.rb][]. If you want to know
all the possible use cases, you can also see: [example/use-cases.rb][]. It's
also served as a test for each possible combinations, so it's quite complex
and complete.

[example/use-cases.rb]: example/use-cases.rb

## rest-core users:

* [rest-firebase](https://github.com/CodementorIO/rest-firebase)
* [rest-more][]
* [rest-more-yahoo_buy](https://github.com/GoodLife/rest-more-yahoo_buy)
* [s2sync](https://github.com/brucehsu/s2sync)
* [s2sync_web](https://github.com/brucehsu/s2sync_web)
* [topcoder](https://github.com/miaout17/topcoder)

## Powered sites:

* [Codementor](https://www.codementor.io/)
* [PicCollage](http://pic-collage.com/)

## CHANGES:

* [CHANGES](CHANGES.md)

## CONTRIBUTORS:

* Andrew Liu (@eggegg)
* andy (@coopsite)
* Barnabas Debreczeni (@keo)
* Bruce Chu (@bruchu)
* Ethan Czahor (@ethanz5)
* Florent Vaucelle (@florent)
* Jaime Cham (@jcham)
* Joe Chen (@joe1chen)
* John Fan (@johnfan)
* khoa nguyen (@khoan)
* Lin Jen-Shin (@godfat)
* lulalala (@lulalala)
* Man Vuong (@kidlab)
* Mariusz Pruszynski (@snicky)
* Mr. Big Cat (@miaout17)
* Nicolas Fouché (@nfo)
* Szu-Kai Hsu (@brucehsu)

## LICENSE:

Apache License 2.0

Copyright (c) 2011-2014, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
