# rest-core [![Build Status](https://secure.travis-ci.org/godfat/rest-core.png?branch=master)](http://travis-ci.org/godfat/rest-core)

by Cardinal Blue <http://cardinalblue.com>

Lin Jen-Shin ([godfat][]) had given a talk about rest-core on
[RubyConf Taiwan 2011][talk]. The slide is in English, but the
talk is in Mandarin.

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
we have developed rest-core, which consists of composable middleware
that allows you to build a REST client for any REST API. Or in the case of
common APIs such as Facebook, Github, and Twitter, you can simply use the
dedicated clients provided by [rest-more][].

[rest-more]: https://github.com/cardinalblue/rest-more

## FEATURES:

* Modular interface for REST clients similar to WSGI/Rack for servers.
* Concurrent requests with synchronous or asynchronous interfaces with
  fibers or threads are both supported.

## REQUIREMENTS:

### Mandatory:

* MRI (official CRuby) 1.9.3, Rubinius 1.9 and JRuby 1.9
* gem rest-client

### Optional:

* gem [em-http-request][] (if using eventmachine)
* gem json or yajl-ruby, or multi_json (if `JsonResponse` or
  `JsonRequest` middlewares are used)

[em-http-request]: https://github.com/igrigorik/em-http-request

## INSTALLATION:

``` shell
gem install rest-core
```

Or if you want development version, put this in Gemfile:

``` ruby
gem 'rest-core', :git => 'git://github.com/cardinalblue/rest-core.git',
                 :submodules => true
```

If you just want to use Facebook or Twitter clients, please take a look at
[rest-more][] which has a lot of clients built with rest-core.

[rest-more]: http://github.com/cardinalblue/rest-more

## Build Your Own Clients:

You can use `RestCore::Builder` to build your own dedicated clients.
Note that `RC` is an alias of `RestCore`

``` ruby
require 'rest-core'
YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonResponse, true
  use RC::CommonLogger, method(:puts)
  use RC::Cache       , nil, 3600
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

You can also make concurrent requests easily:
(see "Advanced Concurrent HTTP Requests -- Embrace the Future" for detail)

``` ruby
a = [client.get('cardinalblue'), client.get('godfat')]
puts "It's not blocking... but doing concurrent requests underneath"
p a.map{ |r| r['name'] } # here we want the values, so it blocks here
puts "DONE"
```

Callback mode also available:

``` ruby
client.get('cardinalblue'){ |v| p v }
puts "It's not blocking... but doing concurrent requests underneath"
client.wait # we block here to wait for the request done
puts "DONE"
```

You can also use `request_full` to retrieve everything including response
status, response headers, and also other rest-core options. But since using
this interface is like using Rack directly, you have to build the env
manually. To help you build the env manually, everything has a default,
including the path.

``` ruby
client.request_full({})[RC::RESPONSE_BODY] # {"message"=>"Not Found"}
# This would print something like this:
# RestCore: Auto   picked: RestCore::RestClient
# RestCore: Future picked: RestCore::Future::FutureThread
# RestCore: spent 1.135713 Requested GET https://api.github.com/users//

client.request_full(RC::REQUEST_PATH => 'cardinalblue')[RC::RESPONSE_STATUS]
client.request_full(RC::REQUEST_PATH => 'cardinalblue')[RC::RESPONSE_HEADERS]
# Headers are normalized with all upper cases and
# dashes are replaced by underscores.

# To make POST (or any other request methods) request:
client.request_full(RC::REQUEST_PATH   => 'cardinalblue',
                    RC::REQUEST_METHOD => :post)[RC::RESPONSE_STATUS] # 404
```

Runnable example is at: [example/simple.rb][]. Please see [rest-more][]
for more complex examples to build clients, and [slides][] from
[rubyconf.tw/2011][rubyconf.tw] for concepts.

[example/simple.rb]: https://github.com/cardinalblue/rest-core/blob/master/example/simple.rb
[rest-more]: https://github.com/cardinalblue/rest-more
[slides]: http://www.godfat.org/slide/2011-08-27-rest-core.html
[rubyconf.tw]: http://rubyconf.tw/2011/#6

## Playing Around:

You can also play around with `RC::Universal` client, which has installed
_all_ reasonable middlewares built-in rest-core. So the above example could
also be achieved by:

``` ruby
require 'rest-core'
client = RC::Universal.new(:site          => 'https://api.github.com/users/',
                           :json_response => true,
                           :log_method    => method(:puts))
client.get('cardinalblue')
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

    use FollowRedirect, 10
    use CommonLogger  , method(:puts)
    use Cache         ,  {}, 600 do
      use ErrorHandler, nil
      use ErrorDetectorHttp
      use JsonResponse, false
    end
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

    rest-core>> get 'https://api.github.com/users/cardinalblue'

will print out the response from Github. You can also do this to make
calling Github easier:

    rest-core>> self.site = 'https://api.github.com/users/'
    rest-core>> self.json_response = true

Then it would do exactly like the original example:

    rest-core>> get 'cardinalblue' # you get a nice parsed hash

This is mostly for fun and experimenting, so it's only included in
[rest-more][] and [rib][]. Please make sure you have both of them
installed before trying this.

[rib]: https://github.com/godfat/rib
[rest-more]: https://github.com/cardinalblue/rest-more

## List of built-in Middlewares:

* `RC::AuthBasic`
* `RC::Bypass`
* `RC::Cache`
* `RC::CommonLogger`
* `RC::DefaultHeaders`
* `RC::DefaultPayload`
* `RC::DefaultQuery`
* `RC::DefaultSite`
* `RC::Defaults`
* `RC::ErrorDetector`
* `RC::ErrorDetectorHttp`
* `RC::ErrorHandler`
* `RC::FollowRedirect`
* `RC::JsonRequest`
* `RC::JsonResponse`
* `RC::Oauth1Header`
* `RC::Oauth2Header`
* `RC::Oauth2Query`
* `RC::Timeout`

## Build Your Own Middlewares:

To be added.

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
puts "rest-client with threads doing concurrent requests"
a = [client.get('cardinalblue'), client.get('godfat')]
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
puts "rest-client with threads doing concurrent requests"
client.get('cardinalblue'){ |v|
         p v['name']
       }.
       get('godfat'){ |v|
         p v['name']
       }
puts "It's not blocking... but doing concurrent requests underneath"
client.wait # until all requests are done
puts "DONE"
```

You can pick whatever works for you.

[future]: http://en.wikipedia.org/wiki/Futures_and_promises

### What Concurrency Model to Choose?

In the above example, we're using rest-client with threads, which works
for most of cases. But you might also want to use em-http-request with
EventMachine, which is using a faster HTTP parser. In theory, it should
be much more efficient than rest-client and threads.

To pick em-http-request, you must run the requests inside the EventMachine's
event loop, and also wrap your request with either a thread or a fiber,
because we can't block the event loop and ask em-http-request to finish
its job making requests.

Here's an example of using em-http-request with threads:

``` ruby
require 'em-http-request'
require 'rest-core'
YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonResponse, true
  use RC::CommonLogger, method(:puts)
end

client = YourClient.new
puts "eventmachine with threads doing concurrent requests"
EM.run{
  Thread.new{
    a = [client.get('cardinalblue'), client.get('godfat')]
    p a.map{ |r| r['name'] } # here we want the values, so it blocks here
    puts "DONE"
    EM.stop
  }
  puts "It's not blocking... but doing concurrent requests underneath"
}
```

And here's an example of using em-http-request with fibers:

``` ruby
require 'fiber'           # remember to require fiber first,
require 'em-http-request' # or rest-core won't pick fibers
require 'rest-core'
YourClient = RC::Builder.client do
  use RC::DefaultSite , 'https://api.github.com/users/'
  use RC::JsonResponse, true
  use RC::CommonLogger, method(:puts)
end

client = YourClient.new
puts "eventmachine with fibers doing concurrent requests"
EM.run{
  Fiber.new{
    a = [client.get('cardinalblue'), client.get('godfat')]
    p a.map{ |r| r['name'] } # here we want the values, so it blocks here
    puts "DONE"
    EM.stop
  }
  puts "It's not blocking... but doing concurrent requests underneath"
}
```

As you can see, both of them are quite similar to each other, because the
idea behind the scene is the same. If you don't know what concurrency model
to pick, start with rest-client since it's the easiest one to setup.

A full runnable example is at: [example/multi.rb][]. If you want to know
all the possible use cases, you can also see: [example/use-cases.rb][]. It's
also served as a test for each possible combinations, so it's quite complex
and complete.

[example/multi.rb]: https://github.com/cardinalblue/rest-core/blob/master/example/multi.rb

[example/use-cases.rb]: https://github.com/cardinalblue/rest-core/blob/master/example/use-cases.rb

## rest-core users:

* [topcoder](https://github.com/miaout17/topcoder)
* [s2sync](https://github.com/brucehsu/s2sync)
* [s2sync_web](https://github.com/brucehsu/s2sync_web)

## Powered sites:

* [PicCollage](http://pic-collage.com/)

## CHANGES:

* [CHANGES](https://github.com/cardinalblue/rest-core/blob/master/CHANGES.md)

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
* Szu-Kai Hsu (@brucehsu)

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
