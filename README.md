# rest-core [![Build Status](http://travis-ci.org/godfat/rest-core.png)](http://travis-ci.org/godfat/rest-core)
by Cardinal Blue <http://cardinalblue.com>

## LINKS:

* [github](http://github.com/cardinalblue/rest-core)
* [rubygems](http://rubygems.org/gems/rest-core)
* [rdoc](http://rdoc.info/projects/cardinalblue/rest-core)
* [mailing list](http://groups.google.com/group/rest-core/topics)

## DESCRIPTION:

A modular Ruby REST client collection/infrastructure.

In an era of web service and mashup, we saw a blooming of REST API. One might
wonder, how do we easily and elegantly use those API? Thanks that now we are
all favoring REST over SOAP, building a dedicated client might not be that
hard. So why not just build the dedicated clients ourselves?

One can simply use pre-built dedicated clients provided by rest-core,
assuming this would be the most cases. Or if someone is not satisfied with
the pre-built ones, one can use pre-built "middlewares" and "apps" provided
by rest-core, to compose and build the dedicated "clients" (s)he prefers.

## REQUIREMENTS:

* Tested with MRI (official ruby) 1.9.2, 1.8.7, and trunk
* Tested with Rubinius (rbx) 1.2.3
* Tested with JRuby 1.6.2

## INSTALLATION:

    gem install rest-core

Or if you want development version, put this in Gemfile:

    gem 'rest-core', :git => 'git://github.com/cardinalblue/rest-core.git'

## SYNOPSIS:

    RestCore::Builder.client('YourClient') do
      use DefaultSite , 'https://api.github.com/users/'
      use JsonDecode  , true
      use CommonLogger, method(:puts)
      use Cache       , {}
      run RestClient
    end

    client = YourClient.new
    client.get('godfat')
    client.get('godfat')

    client.site = 'http://github.com/api/v2/json/user/show/'
    client.get('godfat')
    client.get('godfat')

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
