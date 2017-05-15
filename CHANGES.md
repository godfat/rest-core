# CHANGES

## rest-core 4.0.1 -- 2017-05-15

* [RC::Cache] Check against `Numeric` instead of `Fixnum` for Ruby 2.4
  compatibility.
* [RC::JsonResponse] Fix encoding issue when trying to remove BOM.
  See https://github.com/godfat/rest-core/issues/24
  and https://github.com/godfat/rest-core/commit/4123ca485ecc3b9d31749423f7039bfa1652a3a3
  Thanks AshwiniDoddamaniFluke

## rest-core 4.0.0 -- 2016-02-04

Now the core functionality was extracted to a new gem, rest-builder.
rest-core from now on would just bundle middleware and some utilities.
Things like `RC::Builder` should still work for the sake of compatibility,
but it's actually `RestBuilder::Builder` underneath. Note that the core
concurrency facility was extracted to another new gem, promise_pool.
Since some parts were also rewritten, things might change somehow.
At least no public APIs were changed. It's completely compatible.

### Incompatible changes

* `RC::Simple` was removed. There's no point for that.
* `RC.id` was removed, in favour of `:itself.to_proc`.
* Include `RC::Middleware` would no longer include `RC` as well.

### Enhancements

* We no longer `autoload` a lot of stuffs, rather, we just load it.
* Previously, only when you try to _peek_ the future, the callback would be
  called. From now on, whenever the request is done, it would call the
  callback regardless. However, if there's an exception, it won't be raised.
  It would only raise whenever you _peek_ it. An obvious difference for this
  is the `RC::CommonLogger`. Previously since callback would only be called
  when you _peek_ it, the time would be the difference from request done to
  you _peeked_ it. From now on, it would just be how much time the request
  has been taken, regardless when you _peek_ it.

## rest-core 3.6.0 -- 2016-01-27

### Incompatible changes

* Client.defer would now raise an error if the block would raise an error.

### Enhancements

* EventSource would now try to close the socket (actually, pipe from
  httpclient) if there's no data coming in in 35 seconds,
  (RC::EventSource::READ_WAIT) therefore we could reconnect in this case.
  This is mostly for rest-firebase, reference:
  <https://github.com/CodementorIO/rest-firebase/issues/8>
  We would surely need a way to configure this timeout rather than
  hard coding it for 35 seconds as different services could use different
  timeout. Thanks @volksport for investigating this.

## rest-core 3.5.92 -- 2015-12-28

### Enhancements

* Added `RestCore::DalliExtension` for making `Dalli::Client` walk and quad
  like `Hash` so that you could pass it as a cache client to
  `RestCore::Cache`.

## rest-core 3.5.91 -- 2015-12-11

### Bugs fixed

* Instead of forcing to load `http/cookie_jar/hash_store.rb`, which is only
  available when _http-cookie_ is available, we just initialize httpclient
  and throw it away. Hopefully this would be more compatible between versions.

## rest-core 3.5.9 -- 2015-12-11

### Bugs fixed

* Fixed a potential deadlock or using a partially loaded stuff for
  _httpclient_. We fixed this by requiring eagerly instead of loading
  it lazily. The offender was: _http-cookie_: `http/cookie_jar/hash_store.rb`.
  _httpclient_ could try to load this eagerly or just don't load it since
  we're not using `cookie_manager` anyway. The errors we've seen:
  * `NoMethodError: undefined method `implementation' for HTTP::CookieJar::AbstractStore:Class`
  * `ArgumentError: cookie store unavailable: :hash`
  * deadlock (because it's requiring it in a thread)

## rest-core 3.5.8 -- 2015-12-07

### Enhancements

* Added `Client.defer` for doing arbitrary asynchronous tasks.

## rest-core 3.5.7 -- 2015-09-10

### Incompatible changes

* JSON_REQUEST_METHOD was removed.

### Bugs fixed

* GET/DELETE/HEAD/OPTIONS would no longer try to attach any payload.

### Enhancements

* Introduced Middleware.has_payload? which would detect if the request
  should attach a payload or not.

## rest-core 3.5.6 -- 2015-07-23

### Bugs fixed

* Removed changes shouldn't be made into JsonResponse. My bad.
  I should `git stash` before making releases.

## rest-core 3.5.5 -- 2015-07-22

### Bugs fixed

* Fixed a possible data race for thread pool when enqueuing very quickly.

## rest-core 3.5.4 -- 2015-01-17

### Bugs fixed

* Fixed a regression where callback is not called for `RC::Cache` when cache
  is available.

## rest-core 3.5.3 -- 2015-01-11

### Bugs fixed

* Fixed a regression where timeout is not properly handled for thread pool.

## rest-core 3.5.2 -- 2015-01-09

### Bugs fixed

* Now callbacks would respect `RC::RESPONSE_KEY`.
* Clear `Thread.current[:backtrace]` after done in thread pool to reduce
  memory footprint.
* Fixed backtrace for exception raised in callbacks.
* Fixed some potential corner cases where errors are not properly handled
  when timeout happened.

## rest-core 3.5.1 -- 2014-12-27

* Ruby 2.2 compatibility.

## rest-core 3.5.0 -- 2014-12-09

### Incompatible changes

* `RC::Builder` would now only deep copy arrays and hashes.
* `RC::ErrorHandler`'s only responsibility is now creating the exception.
  Raising the exceptions or passing it to the callback is now handled by
  `RC::Client` instead. (Thanks Andrew Clunis, #6)
* Since exceptions are raised by `RC::Client` now, `RC::Timeout` would not
  raise any exception, but just hand over to `RC::Client`.
* Support for Ruby version < 1.9.2 is dropped.

### Bugs fixed

* Reverted #10 because it caused the other encoding issue. (#12)
* `RC::Client#wait` and `RC::Client.wait` would now properly wait for
  `RC::FollowRedirect`
* `RC::Event::CacheHit` is properly logged again.

### Enhancements

* Introduced `RC::Client#error_callback` which would get called for each
  exceptions raised. This is useful for monitoring and logging errors.

* Introduced `RC::Retry` which could retry the request upon certain errors.
  Specify `max_retries` for maximum times for retrying, and `retry_exceptions`
  for which exceptions should be trying.
  Default is `[IOError, SystemCallError]`

* Eliminated a few warnings when `-w` is used.

## rest-core 3.4.1 -- 2014-11-29

### Bugs fixed

* Handle errors for `RC::EventSource` more conservatively to avoid any
  potential deadlock.

* It would not deadlock even if logging failed.

## rest-core 3.4.0 -- 2014-11-26

### Incompatible changes

* Removed rest-client support.
* Removed net-http-persistent support.
* Removed patch for old multi-json.

### Bugs fixed

* `RC::JsonRequest` can now POST, PUT, or PATCH with a single `false`.

* Previously, we're not handling timeout correctly. We left all that to
  httpclient, and which would raise `HTTPClient::ConnectTimeoutError` and
  `HTTPClient::ReceiveTimeoutError`. The problem is that connecting and
  receiving are counted separately. That means, if we have 30 seconds timeout,
  we might be ending up with 58 seconds requesting time, for 29 seconds
  connecting time and 29 seconds receiving time. Now it should probably
  interrupt the request in 30 seconds by handling this by ourselves with a
  timer thread in the background. The timer thread would be shut down
  automatically if there's no jobs left, and it would recreate the thread
  when there's a job comes in, keeping working until there's no jobs left.

### Enhancements

* Introduced `RC::Timer.interval` which is the interval to check if there's
  a request timed out. The default interval is 1 second, which means it would
  check if there's a request timed out for every 1 second. This also means
  timeout with less than 1 second won't be accurate at all. You could
  decrease the value if you need timeout less than 1 second, or increase it
  if your timeout is far from 30 second by calling `RC::Timer.interval = 5`.

## rest-core 3.3.3 -- 2014-11-07

### Bugs fixed

* `RC::EventSource` would now properly reconnect for SystemCallError such as
  `Errno::ECONNRESET`.

* It would now always emit a warning whenever there's an exception raised
  asynchronously.

* All exceptions raised from a thread or thread pool would now have a
  proper backtrace. This was fixed by introducing `RC::Promise.backtrace`

### Enhancements

* Introduced `RC::Promise.backtrace`. Using this in a callback could give you
  proper backtrace, comparing to `caller` would only give you the backtrace
  for current thread.

* Introduced `RC::Promise.set_backtrace`. Using this we could set exceptions
  with proper backtrace.

## rest-core 3.3.2 -- 2014-10-11

* Just use `File.join` for `RC::DefaultSite` as `File::SEPARATOR` is
  universally `/` and it would not try to raise exceptions for improperly
  encoded URI. #11 Man Vuong (@kidlab)

## rest-core 3.3.1 -- 2014-10-08

* `RC::Oauth1Header` would now properly encode queries in oauth_callback.
  rest-more#6 khoa nguyen (@khoan)

* Made all literal regular expression UTF-8 encoded, fixing encoding issue
  on JRuby. #10 Joe Chen (@joe1chen)

* Now `RC::DefaultSite` would use `URI.join` to prepend the default site,
  therefore eliminating duplicated / or missing /. #11 Man Vuong (@kidlab)

* Fixed deprecation warnings from `URI.escape`. Lin Jen-Shin (@godfat)

* Now we properly wait for the callback to be called to consider the request
  is done. Lin Jen-Shin (@godfat)

## rest-core 3.3.0 -- 2014-08-25

### Incompatible changes

* Removed `RC::Wrapper`. Apparently it's introducing more troubles than the
  benefit than it brings. Currently, only `RC::Cache` is really using it,
  and now the old functionality is merged back to `RC::Builder`.

* Therefore `RC::Cache` is no longer accepting a block.

* `RC::Universal` is then updated accordingly to respect the new `RC::Cache`.

### Enhancements

* Now `RC::DefaultQuery`, `RC::DefaultPayload`, and `RC::DefaultHeaders`
  work the same way. Previously they merge hashes slightly differently.

* Introduced `RC::Middleware#member=` in addition to `RC::Middleware#member`.

* RC::JsonResponse would now strip the problematic UTF-8 BOM before parsing.
  This was introduced because Stackoverflow would return it. We also
  try to not raise any encoding issues here.

## rest-core 3.2.0 -- 2014-06-27

### Enhancements

* Introduced `RC::JsonResponse::ParseError` which would be a subclass of
  `RC::Json::ParseError`, and contain the original text before parsing.
  This should be great for debugging. For example, some servers might
  return HTML instead JSON, and we would like to read the HTML to learn
  more why they are doing this.

* Introduced `RC::ParseLink` utility for parsing web links described in
  [RFC5988](http://tools.ietf.org/html/rfc5988)

* Introduced `RC::Clash` which is a hash wrapper protecting you from getting
  nils from hashes. This is useful whenever we want to access a value deeply
  inside a hash. For example: `json['a']['b']['c']['d']` would never fail
  due to nils. Note that `RC::Clash` is recursive.

* Introduced `RC::Smash` which is a hash wrapper protecting you from getting
  nils from hashes. This is useful whenever we want to access a value deeply
  inside a hash. Instead of using multiple layers of subscript operators,
  we try to use a "path" to specify which value we want. For example:
  `json['a', 'b', 'c', 'd']` is the same as `json['a']['b']['c']['d']` but
  with protection from nils in the middle. Note that `RC:Smash` is *not*
  recursive.

* Introduced `RC::ClashResponse` which would wrap the response inside
  `RC::Clash`. This is useful along with `RC::JsonResponse`.

* Introduced `RC::SmashResponse` which would wrap the response inside
  `RC::Smash`. This is useful along with `RC::JsonResponse`.

* Introduced `RC::Client.shutdown` which is essentially the same as
  `RC::Client.thread_pool.shutdown` and `RC::Client.wait`.

* `RC::ClashResponse` and `RC::SmashResponse` is added into `RC::Universal`
  with `{:clash_response => false, :smash_response => false}` by default.

* Introduced `RC::Promise#future_response` to allow you customize the
  behaviour of promises more easily.

* Introduced `RC::Promise.claim` to allow you pre-fill a promise.

* Introduced `RC::Promise#then` to allow you append a callback whenever
  the response is ready. The type should be: `Env -> Response`

* Now `RC::Promise#inspect` would show REQUEST_URI instead of REQUEST_PATH,
  which should be easier to debug.

* Introduced `RC::ThreadPool#size` which is a short hand for
  `RC::ThreadPool#workers.size`.

### Bugs fixed

* Inheritance with `RC::Client` now works properly.
* Now `RC::Cache` properly return cached headers.
* Now `RC::Cache` would work more like `RC::Engine`, wrapping responses
  inside futures.

## rest-core 3.1.1 -- 2014-05-13

### Enhancements

* Introduced `RC::Client.wait` along with `RC::Client#wait`. It would collect
  all the promises from all instances of the client, so we could wait on all
  promises we're waiting. This would make writing graceful shutdown much
  easier. For example, we could have: `at_exit{ RC::Universal.wait }` to
  wait on all requests from the universal client before exiting the process.

## rest-core 3.1.0 -- 2014-05-09

### Incompatible changes

* Now that the second argument `key` in `RC::Client#request` is replaced by
  `RC::RESPONSE_KEY` passed in env. This would make it easier to use and
  more consistent internally.
* Now RC::EventSource#onmessage would receive the event in the first argument,
  and the data in the second argument instead of a hash in the first argument.

### Enhancements

* Added RC::REQUEST_URI in the env so that we could access the requesting
  URI easily.
* Added middleware RC::QueryResponse which could parse query in response.
* Added RC::Client.event_source_class which we could easily swap the class
  used for event_source. Used in Firebase client to parse data in JSON.
* Now methods in RC::EventSource would return itself so that we could chain
  callbacks.
* Added RC::EventSource#onreconnect callback to handle if we're going to
  reconnect automatically or not.
* RC::Config was extracted from rest-more, which could help us manage config
  files.
* RC::Json using JSON would now parse in quirks_mode, so that it could parse
  not only JSON but also a single value.

### Bugs Fixes

* We should never cache hijacked requests.
* Now we preserve payload and properly ignore query for RC::FollowRedirect.

## rest-core 3.0.0 -- 2014-05-04

Highlights:

* Hijack for streaming responses
* EventSource for SSE (server-sent events)
* Thread pool
* Keep-alive connections from httpclient

### Incompatible changes

* Since eventmachine is buggy, and fibers without eventmachine doesn't make
  too much sense, we have removed the support for eventmachine and fibers.

* We also changed the default HTTP client from rest-client to httpclient.
  If you still want to use rest-client, switch it like this:

      RC::Builder.default_engine = RC::RestClient

  Be warned, we might remove rest-client support in the future.

* `RC::Client#options` would now return the headers instead of response body.

* Removed support for Ruby 1.8.7 without openssl installed.

* `RC::Future` is renamed to `RC::Promise`, and `RC::Future::Proxy` is
  renamed to `RC::Promise::Future`.

### Enhancements

* HIJACK support, which is similar to Rack's HIJACK feature. If you're
  passing `{RC::HIJACK => true}` whenever making a request, rest-core would
  rather set the `RC::RESPONSE_BODY` as an empty string, and set
  `RC::RESPONSE_SOCKET` as a socket for the response. This is used for
  `RC::EventSource`, and you could also use this for streaming the response.
  Note that this only works for default engine, httpclient.

* Introduce `RC::EventSource`. You could obtain the object via
  `RC::Client#event_source`, and then setup `onopen`, `onmessage`, and
  `onerror` respectively, and then call `RC::EventSource#start` to begin
  making the request, and receive the SSE (sever-sent events) from the server.
  This is used in `RC::Firebase` from rest-more.

* Now we have thread pool support. We could set the pool size with:
  `RC::YourClient.pool_size = 10` and thread idle time with:
  `RC::YourClient.pool_idle_time = 60`. By default, `pool_size` is 0
  which means we don't use a thread pool. Setting it to a negative number
  would mean do not spawn any threads, just make a blocking request.
  `pool_idle_time` is default to 60, meaning an idle thread would be shut
  down after 60 seconds without being used.

* Since we're now using httpclient by default, we should also take the
  advantage of using keep-alive connections for the same host.

* Now `RC::Middleware#fail` and `RC::Middleware#log` could accept `nil` as
  an input, which would then do nothing. This could much simplify the code
  building middleware.

* Now we're using timers gem which should be less buggy from previous timeout.

## rest-core 2.1.2 -- 2013-05-31

### Incompatible changes

* Remove support for Ruby < 1.9.2

### Bugs fixes

* [`Client`] Fixed a bug where if we're using duplicated attributes.

## rest-core 2.1.1 -- 2013-05-21

### Bugs fixes

* Fixed em-http-request support.

### Enhancements

* [`Payload`] Now it is a class rather than a module.
* [`Paylaod`] Introduced `Payload.generate_with_headers`.
* [`Paylaod`] Give a `nil` if payload passing to `Payload.generate` should
  not have any payload at all.

## rest-core 2.1.0 -- 2013-05-08

### Incompatible changes

* We no longer support Rails-like POST payload, like translating
  `{:foo => [1, 2]}` to `'foo[]=1&foo[]=2'`. It would now be translated to
  `'foo=1&foo=2'`. If you like `'foo[]'` as the key, simply pass it as
  `{'foo[]' => [1, 2]}`.

* This also applies to nested hashes like `{:foo => {:bar => 1}`. If you
  want that behaviour, just pass `{'foo[bar]' => 1}` which would then be
  translated to `'foo[bar]=1'`.

### Bugs fixes

* [`Payload`] Now we could correctly support payload with "foo=1&foo=2".
* [`Client`] Fix inspect spacing.

### Enhancements

* [`Payload`] With this class introduced, replacing rest-client's own
  payload implementation, we could pass StringIO or other sockets as the
  payload body. This would also fix the issue that using the same key for
  different values as allowed in the spec.
* [`EmHttpRequest`] Send payload as a file directly if it's a file. Buffer
  the payload into a tempfile if it's from a socket or a large StringIO.
  This should greatly reduce the memory usage as we don't build large
  Ruby strings in the memory. Streaming is not yet supported though.
* [`Client`] Make inspect shorter.
* [`Client`] Introduce Client#default_env
* [`Middleware`] Introduce Middleware.percent_encode.
* [`Middleware`] Introduce Middleware.contain_binary?.

## rest-core 2.0.4 -- 2013-04-30

* [`EmHttpRequest`] Use `EM.schedule` to fix thread-safety issue.

## rest-core 2.0.3 -- 2013-04-01

* Use `URI.escape(string, UNRESERVED)` for URI escaping instead of
  `CGI.escape`

* [`Defaults`] Use `respond_to_missing?` instead of `respond_to?`

## rest-core 2.0.2 -- 2013-02-07

### Bugs fixes

* [`Cache`] Fix cache with multiline response body. This might invalidate
  your existing cache.

## rest-core 2.0.1 -- 2013-01-08

### Bugs fixes

* Don't walk into parent's constants in `RC.eagerload`.
* Also rescue `NameError` in `RC.eagerload`.

### Enhancements

* Remove unnecessary `future.wrap` in `EmHttpRequest`.
* Introduce Future#callback_in_async.
* We would never double resume the fiber, so no need to rescue `FiberError`.

## rest-core 2.0.0 -- 2012-10-31

This is a major release which introduces some incompatible changes.
This is intended to cleanup some internal implementation and introduce
a new mechanism to handle multiple requests concurrently, avoiding needless
block.

Before we go into detail, here's who can upgrade without changing anything,
and who should make a few adjustments in their code:

* If you're only using rest-more, e.g. `RC::Facebook` or `RC::Twitter`, etc.,
  you don't have to change anything. This won't affect rest-more users.
  (except that JsonDecode is renamed to JsonResponse, and json_decode is
  renamed to json_response.)

* If you're only using rest-core's built in middlewares to build your own
  clients, you don't have to change anything as well. All the hard works are
  done in rest-core. (except that ErrorHandler works a bit differently now.
  We'll talk about detail later.)

* If you're building your own middlewares, then you are the ones who need to
  make changes. `RC::ASYNC` is changed to a flag to mean whether the callback
  should be called directly, or only after resuming from the future (fiber
  or thread). And now you have always to get the response from `yield`, that
  is, you're forced to pass a callback to `call`.

  This might be a bit user unfriendly at first glimpse, but it would much
  simplify the internal structure of rest-core, because in the middlewares,
  you don't have to worry if the user would pass a callback or not, branching
  everywhere to make it work both synchronously and asynchronously.

  Also, the old fiber based asynchronous HTTP client is removed, in favor
  of the new _future_ based approach. The new one is more like a superset
  of the old one, which have anything the old one can provide. Yet internally
  it works a lot differently. They are both synchronous to the outsides,
  but while the old one is also synchronous inside, the new one is
  asynchronous inside, just like the purely asynchronous HTTP client.

  That is, internally, it's always asynchronously, and fiber/async didn't
  make much difference here now. This is also the reason why I removed
  the old fiber one. This would make the middleware implementation much
  easier, considering much fewer possible cases.

  If you don't really understand what above does mean, then just remember,
  now we ask all middlewares work asynchronously. You have always to work
  with callbacks which passed along in `app.call(env){ |response| }`
  That's it.

So what's the most important improvement? From now on, we have only two
modes. One is callback mode, in which case `env[ASYNC]` would be set, and
the callback would be called. No exception would be raised in this case.
If there's an exception, then it would be passed to the block instead.

The other mode, which is synchronous, is achieved by the futures. We have
two different kinds of futures for now, one is thread based, and the other
is fiber based. For RestClient, thread based future would be used. For
EventMachine, depending on the context, if the future is created on the
main thread, then it would assume it's also wrapped inside a fiber. Since,
we can never block the event loop! If you're not calling it in a thread,
you must call it in a fiber. But if you're calling it in a thread, then
the thread based future would be picked. This is because otherwise it won't
work well exchanging information around threads and fibers.

In short, rest-core would run concurrently in all contexts, archived by
either threads or fibers depending on the context, and it would pick the
right strategy for you.

You can see [use-cases.rb][] for all possible use cases.

It's a bit outdated, but you can also checkout my blog post.
[rest-core 2.0 roadmap, thunk based response][post]
(p.s. now thunk is renamed to future)

[use-cases.rb]: https://github.com/godfat/rest-core/blob/master/example/use-cases.rb
[post]: http://blogger.godfat.org/2012/06/rest-core-20-roadmap-thunk-based.html

### Incompatible changes

* [JsonDecode] is renamed to JsonResponse, and json_decode is also renamed
  to json_response.
* [Json] Now you can use `Json.decode` and `Json.encode` to parse and
  generate JSONs, instead of `JsonDecode.json_decode`.
* [Cache] Support for "cache.post" is removed.
* [Cache] The cache key is changed accordingly to support cache for headers
  and HTTP status. If you don't have persistent cache, this doesn't matter.

* [EmHttpRequestFiber] is removed in favor of `EmHttpRequest`
* cool.io support is removed.
* You must provide a block to `app.call(env){ ... }`.
* Rename Wrapper#default_app to Wrapper#default_engine

### Enhancements

* The default engine is changed from `RestClient` to `Auto`, which would
  be using `EmHttpRequest` under the context of a event loop, while
  use `RestClient` in other context as before.

* `RestCore.eagerload` is introduced to load all constants eagerly. You can
  use this before loading the application to avoid thread-safety issue in
  autoload. For the lazies.

* [JsonResponse] This is originally JsonDecode, and now we prefer multi_json
  first, yajl-ruby second, lastly json.
* [JsonResponse] give JsonResponse a default header Accept: application/json,
  thanks @ayamomiji
* [JsonRequest] This middleware would encode your payload into a JSON.
* [CommonLogger] Now we log the request method as well.
* [DefaultPayload] Accept arbitrary payload.
* [DefaultQuery] Now before merging queries, converting every single key into
  a string. This allows you to use :symbols for default query.

* [ErrorHandler] So now ErrorHandler is working differently. It would first
  try to see if `env[FAIL]` has any exception in it. If there is, then raise
  it. Otherwise it would call error_handler and expect it to generate an
  error object. If the error object is an exception, then raise it. If it's
  not, then it would merge it into `env[FAIL]`. On the other hand, in the
  case of using callbacks instead of futures, it would pass the exception
  as the `env[RESPONSE_BODY]` instead. The reason is that you can't raise
  an exception asynchronously and handle it safely.

* [Cache] Now response headers and HTTP status are also cached.
* [Cache] Not only GET requests are cached, HEAD and OPTIONS are cached too.
* [Cache] The cache key is also respecting the request headers too. Suppose
  you're making a request with different Accept header.

* [Client] Add Client#wait which would block until all requests for this
  particular client are done.

### Bugs fixes

* [Middleware] Sort the query before generating the request URI, making
  sure the order is always the same.
* [Middleware] The middleware could have no members at all.
* [ParseQuery] The fallback function for the absence of Rack is fixed.
* [Auto] Only use EmHttpRequest if em-http-request is loaded,
  thanks @ayamomiji

## rest-core 1.0.3 -- 2012-08-15

### Enhancements

* [Client] `client.head` now returns the headers instead of response body.
  It doesn't make sense to return the response body, because there's no
  such things in a HEAD request.

### Bugs fixes

* [Cache] The cache object you passed in would only need to respond to
  `[]` and `[]=`. If the cache object accepts an `:expires_in` option,
  then it must also respond to `store`, too.

* [Oauth1Header] Fixed a long standing bug that tilde (~) shouldn't be
  escaped. Many thanks to @brucehsu for discovering this!

## rest-core 1.0.2 -- 2012-06-05

### Enhancements

* Some internal refactoring.

### Bugs fixes

* Properly handle asynchronous timers for eventmachine and cool.io.

## rest-core 1.0.1 -- 2012-05-14

* [`Auto`] Check for eventmachine first instead of cool.io
* [`EmHttpRequestFiber`] Also pass callback for errback
* [`DefaultQuery`] Make default query to {} instead of nil

## rest-core 1.0.0 -- 2012-03-17

This is a very significant release. The most important change is now we
support asynchronous requests, by either passing a callback block or using
fibers in Ruby 1.9 to make the whole program still look synchronous.

Please read [README.md](https://github.com/godfat/rest-core/blob/master/README.md)
or [example](https://github.com/godfat/rest-core/tree/master/example)
for more detail.

* [`Client`] Client#inspect is fixed for clients which do not have any
  attributes.

* [`Client`] HEAD, OPTIONS, and PATCH requests are added. For example:

  ``` ruby
      client = Client.new
      client.head('path')
      client.options('path')
      client.patch('path')
  ```

* [`Client`] Now if you passed a block to either `get` or `post` or other
  requests, the response would be returned to the block instead the caller.
  In this case, the return value of `get` or `post` would be the client
  itself. For example:

  ``` ruby
      client = Client.new
      client.get('path'){ |response| puts response.insepct }.
             get('math'){ |response| puts response.insepct }
  ```

* [`RestClient`] Now all the response headers names are converted to upper
  cases and underscores (_). Also, if a header has only presented once, it
  would not be wrapped inside an array. This is more consistent with
  em-http-request, cool.io-http, and http_parser.rb

* [`RestClient`] From now on, the default HTTP client, i.e. `RestClient` won't
  follow any redirect. To follow redirect, please use `FollowRedirect`
  middleware. Two reasons. One is that the underlying HTTP client should
  be minimal. Another one is that a FollowRedirect middleware could be
  used for all HTTP clients. This would make it more consistent across
  all HTTP clients.

* [`RestClient`] Added a patch to avoid `"123".to_i` returning `200`,
  please see: <https://github.com/archiloque/rest-client/pull/103>
  I would remove this once after this patch is merged.

* [`RestClient`] Added a patch to properly returning response whenever
  a redirect is happened. Please see:
  <https://github.com/archiloque/rest-client/pull/118>
  I would remove this once after this patch is merged.

* [`FollowRedirect`] This middleware would follow the redirect. Pass
  :max_redirects for the maximum redirect times. For example:

  ``` ruby
      Client = RestCore::Builder.client do
        use FollowRedirect, 2 # default :max_redirects
      end
      client = Client.new
      client.get('path', {}, :max_redirects => 5)
  ```

* [`Middleware`] Added `Middleware#run` which can return the underlying HTTP
  client, if you need to know the underlying HTTP client can support
  asynchronous requests or not.

* [`Cache`] Now it's asynchrony-aware.
* [`CommonLogger`] Now it's asynchrony-aware.
* [`ErrorDetector`] Now it's asynchrony-aware.
* [`ErrorHandler`] Now it's asynchrony-aware.
* [`JsonDecode`] Now it's asynchrony-aware.
* [`Timeout`] Now it's asynchrony-aware.

* [`Universal`] `FollowRedirect` middleware is added.
* [`Universal`] `Defaults` middleware is removed.

* Added `RestCore::ASYNC` which should be the callback function which is
  called whenever the response is available. It's similar to Rack's
  async.callback.

* Added `RestCore::TIMER` which is only used in Timeout middleware. We need
  this to disable timer whenever the response is back.

* [`EmHttpRequestAsync`] This HTTP client accepts a block to make asynchronous
  HTTP requests via em-http-request gem.

* [`EmHttpRequestFiber`] This HTTP client would make asynchronous HTTP
  requests with em-http-request but also wrapped inside a fiber, so that it
  looks synchronous to the program who calls it.

* [`EmHttpRequest`] This HTTP client would would use `EmHttpRequestAsync` if
  a block (`RestCore::ASYNC`) is passed, otherwise use `EmHttpRequestFiber`.

* [`CoolioAsync`] This HTTP client is basically the same as
  `EmHttpRequestAsync`, but using cool.io-http instead of em-http-request.

* [`CoolioFiber`] This HTTP client is basically the same as
  `EmHttpRequestFiber`, but using cool.io-http instead of em-http-request.

* [`Coolio`] This HTTP client is basically the same as `EmHttpRequest`,
    but using cool.io-http instead of em-http-request.

* [`Auto`] This HTTP client would auto-select a suitable client. Under
  eventmachine, it would use `EmHttpRequest`. Under cool.io, it would use
  `Coolio`. Otherwise, it would use `RestClient`.

## rest-core 0.8.2 -- 2012-02-18

### Enhancements

* [`DefaultPayload`] This middleware allows you to have default payload for
  POST and PUT requests.

* [`Client`] Now `lighten` would give all Unserializable to nil instead of
  false

### Bugs fixes

* [`ErrorDetector`] Now it would do nothing instead of crashing if there's no
  any error_detector.

## rest-core 0.8.1 -- 2012-02-09

### Enhancements

* [`Wrapper`] Introducing `Wrapper.default_app` (also `Builder.default_app`)
  which you can change the default app from `RestClient` to other HTTP
  clients.

### Bugs fixes

* [`OAuth1Header`] Correctly handle the signature when it comes to multipart
  requests.

* [`ErrorDetectorHttp`] Fixed argument error upon calling `lighten` for
  clients using this middleware. (e.g. rest-more's Twitter client)

## rest-core 0.8.0 -- 2011-11-29

Changes are mostly related to OAuth.

### Incompatible changes

* [`OAuth1Header`] `callback` is renamed to `oauth_callback`
* [`OAuth1Header`] `verifier` is renamed to `oauth_verifier`

* [`Oauth2Header`] The first argument is changed from `access_token` to
  `access_token_type`. Previously, the access_token_type is "OAuth" which
  is used in Mixi. But mostly, we might want to use "Bearer" (according to
  [OAuth 2.0 spec][]) Argument for the access_token is changed to the second
  argument.

* [`Defaults`] Now we're no longer call `call` for any default values.
  That is, if you're using this: `use s::Defaults, :data => lambda{{}}`
  that would break. Previously, this middleware would call `call` on the
  lambda so that `data` is default to a newly created hash. Now, it would
  merely be default to the lambda. To make it work as before, please define
  `def default_data; {}; end` in the client directly. Please see
  `OAuth1Client` as an example.

[OAuth 2.0 spec]: http://tools.ietf.org/html/draft-ietf-oauth-v2-22

### Enhancements

* [`AuthBasic`] Added a new middleware which could do
  [basic authentication][].

* [`OAuth1Header`] Introduced `data` which is a hash and is used to store
  tokens and other information sent from authorization servers.

* [`ClientOauth1`] Now `authorize_url!` accepts opts which you can pass
  `authorize_url!(:oauth_callback => 'http://localhost/callback')`.

* [`ClientOauth1`] Introduced `authorize_url` which would not try to ask
  for a request token, instead, it would use the current token as the
  request token. If you don't understand what does this mean, then keep
  using `authorize_url!`, which would call this underneath.

* [`ClientOauth1`] Introduced `authorized?`
* [`ClientOauth1`] Now it would set `data['authorized'] = 'true'` when
  `authorize!` is called, and it is also used to check if we're authorized
  or not in `authorized?`

* [`ClientOauth1`] Introduced `data_json` and `data_json=` which allow you to
  serialize and deserialize `data` with JSON along with a `sig` to check
  if it hasn't been changed. You can put this into browser cookie. Because
  of the `sig`, you would know if the user changed something in data without
  using `consumer_secret` to generate a correct sig corresponded to the data.

* [`ClientOauth1`] Introduced `oauth_token`, `oauth_token=`,
  `oauth_token_secret`, `oauth_token_secret=`, `oauth_callback`,
  and `oauth_callback=` which take the advantage of `data`.

* [`ClientOauth1`] Introduced `default_data` which is a hash.

[basic authentication]: http://en.wikipedia.org/wiki/Basic_access_authentication

## rest-core 0.7.2 -- 2011-11-04

* Moved rib-rest-core to [rest-more][]
* Moved `RestCore::Config` to [rest-more][]
* Renamed `RestCore::Vendor` to `RestCore::ParseQuery`

## rest-core 0.7.0 -- 2011-10-08

### IMPORTANT CHANGE!

From now on, prebuilt clients such as `RC::Facebook`, `RC::Twitter` and
others are moved to [rest-more][]. Since bundler didn't like cyclic
dependency, so rest-core is not depending on rest-more. Please install
_rest-more_ if you want to use them.

[rest-more]: https://github.com/godfat/rest-more

## rest-core 0.4.0 -- 2011-09-26

### Incompatible changes

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

### Compatible changes

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

[rest-graph]: https://github.com/godfat/rest-graph

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
