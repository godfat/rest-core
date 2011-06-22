
## NOTE

In an era of web service and mashup, we saw a blooming of REST API. One might
wonder, how do we easily and elegantly use those API? We might first try to
find dedicated clients for each web service. It might work pretty well for
the web services using dedicated clients which are designed for, but lately
found that those dedicated clients might not work well together, because
they might have different dependencies with the same purpose, and they might
conflict with each other, or they might be suffering from dependencies hell
or code bloat.

This might not be a serious issue because that we might only use one or two
web services. But we are all growing, so do our applications. At some point,
the complexity of our applications might grow into something that are very
hard to control. Then we might want to separate accessing each web service
with each different process, say, different dedicated workers. So that we
won't be suffering from the issues described above.

Yes this would work, definitely. But this might require more efforts than
it should be. If the dedicated clients can work together seamlessly, then
why not? On the other hand, what if there's no dedicated client at the
moment for the web service we want to access?

Thanks that now we are all favoring REST over SOAP, building a dedicated
client might not be that hard. So why not just build the dedicated clients
ourselves? Yet there's still another issue. We're not only embracing REST,
but also JSON. We would want some kind of JSON support for our hand crafted
clients, but we don't want to copy codes from client A to client B. That's
not so called DRY. We want reusable components, composing them together,
adding some specific features for some particular web service, and then we
get the dedicated clients, not only a generic one which might work for any
web service, but dedicated clients make us feel smooth to use for the
particular web service.

[rest-core][] is invented for that, inspired by [Rack][] and [Faraday][]. One
can simply use pre-built dedicated clients provided by rest-core, assuming
this would be the most cases. Or if someone is not satisfied with the
pre-built ones, one can use pre-built "middlewares" and "apps" provided by
rest-core, to compose and build the dedicated clients (s)he prefers. Or, even
go further that create custom "middlewares", which should be fairly easy,
and use that along with pre-built ones to compose a very customized client.

We present you rest-core.

[rest-core]: https://github.com/cardinalblue/rest-core
[Rack]: https://github.com/rack/rack
[Faraday]: https://github.com/technoweenie/faraday
