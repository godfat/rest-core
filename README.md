# rest-core [![Build Status](http://travis-ci.org/godfat/rest-core.png)](http://travis-ci.org/godfat/rest-core)
by Cardinal Blue <http://cardinalblue.com>

## LINKS:

* [github](http://github.com/cardinalblue/rest-core)
* [rubygems](http://rubygems.org/gems/rest-core)
* [rdoc](http://rdoc.info/projects/cardinalblue/rest-core)
* [mailing list](http://groups.google.com/group/rest-core/topics)

## DESCRIPTION:

A modular Ruby REST client collection/infrastructure.

In this era of web services and mashups, we have seen a blooming of REST APIs.
One might wonder, how do we use these API easily and elegantly? Since REST is
simple (compared to SOAP and older APIs), it is possible to a build a
dedicated client ourselves.

We have developed “rest-core” with the core functionality needed for a REST
client. In the cases of common APIs such as Facebook and Twitter, developers
can simply use the pre-built dedicated clients provided by rest-core. It is
also possible for developers to build custom clients for arbitrary REST APIs
using the middleware provided by rest-core.

## REQUIREMENTS:

* Tested with MRI (official ruby) 1.9.2, 1.8.7, and trunk
* Tested with Rubinius (rbx) 1.2.3
* Tested with JRuby 1.6.2

## INSTALLATION:

    gem install rest-core

Or if you want development version, put this in Gemfile:

    gem 'rest-core', :git => 'git://github.com/cardinalblue/rest-core.git'

## EXAMPLE:

    RestCore::Builder.client('YourClient') do
      use DefaultSite , 'https://api.github.com/users/'
      use JsonDecode  , true
      use CommonLogger, method(:puts)
      use Cache       , {}, nil
      run RestClient
    end

    client = YourClient.new
    client.get('godfat')
    client.get('godfat')

    client.site = 'http://github.com/api/v2/json/user/show/'
    client.get('godfat')
    client.get('godfat')

See [example][] for more complex examples, and [build-in clients][] for even
more complex examples.

[example]: https://github.com/cardinalblue/rest-core/tree/master/example
[build-in clients]: https://github.com/cardinalblue/rest-core/tree/master/lib/rest-core/client

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
