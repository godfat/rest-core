# rest-core [![Build Status](http://travis-ci.org/godfat/rest-core.png)](http://travis-ci.org/godfat/rest-core)
by Cardinal Blue <http://cardinalblue.com>

## LINKS:

* [github](https://github.com/cardinalblue/rest-core)
* [rubygems](http://rubygems.org/gems/rest-core)
* [rdoc](http://rdoc.info/projects/cardinalblue/rest-core)
* [mailing list](http://groups.google.com/group/rest-core/topics)

## DESCRIPTION:

A modular Ruby REST client collection/infrastructure.

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

    # below is exactly the same as [rest-graph][]
    require 'rest-core/client/rest-graph'
    RestGraph.new.get('4')                   # get user info

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
