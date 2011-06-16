# rest-core
by Cardinal Blue <http://cardinalblue.com>

## LINKS:

* [github](http://github.com/cardinalblue/rest-core)
* [rubygems](http://rubygems.org/gems/rest-core)
* [rdoc](http://rdoc.info/projects/cardinalblue/rest-core)
* [mailing list](http://groups.google.com/group/rest-core/topics)

## DESCRIPTION:

A modular and lightweight Ruby REST client infrastructure and implementations

## WARNING:

rest-core is still under heavy development, tests from [rest-graph][]
can't even be run! Everything might change under this phase.
This would be the new core of rest-graph.

[rest-graph]: https://github.com/cardinalblue/rest-graph

## REQUIREMENTS:

* Tested with MRI 1.8.7 and 1.9.2 and Rubinius 1.2.2.
  Because of development gems can't work well on JRuby,
  let me know if rest-core is working on JRuby, thanks!

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

  Copyright (c) 2010, Cardinal Blue

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     <http://www.apache.org/licenses/LICENSE-2.0>

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
