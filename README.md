# rest-builder [![Build Status](https://secure.travis-ci.org/godfat/rest-builder.png?branch=master)](http://travis-ci.org/godfat/rest-builder) [![Coverage Status](https://coveralls.io/repos/github/godfat/rest-builder/badge.png)](https://coveralls.io/github/godfat/rest-builder) [![Join the chat at https://gitter.im/godfat/rest-builder](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/godfat/rest-builder)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/rest-builder)
* [rubygems](https://rubygems.org/gems/rest-builder)
* [rdoc](http://rdoc.info/projects/godfat/rest-builder)
* [issues](https://github.com/godfat/rest-builder/issues) (feel free to ask for support)

## DESCRIPTION:

Modular Ruby clients interface for REST APIs.

Build your own API clients for less dependencies, less codes, less memory,
less conflicts, and run faster. Checkout [rest-core][] for pre-built
middleware and [rest-more][] for pre-built clients.

[rest-core]: https://github.com/godfat/rest-core
[rest-more]: https://github.com/godfat/rest-more

## FEATURES:

* Modular interface for REST clients similar to WSGI/Rack for servers.
* Concurrent requests with synchronous or asynchronous interfaces with
  threads via [promise_pool][].

## WHY?

This was extracted from [rest-core][] because rest-core itself is getting
too complex, and this would be the new core of rest-core. Naming it
rest-core-core is a bit silly, and due to compatibility reason,
rest-core should work as is.

## REQUIREMENTS:

### Mandatory:

* Tested with MRI (official CRuby) and JRuby.
* gem [promise_pool][]
* gem [timers][]
* gem [httpclient][]
* gem [mime-types][]

[promise_pool]: https://github.com/godfat/promise_pool
[timers]: https://github.com/celluloid/timers
[httpclient]: https://github.com/nahi/httpclient
[mime-types]: https://github.com/halostatue/mime-types

## INSTALLATION:

``` shell
gem install rest-builder
```

Or if you want development version, put this in Gemfile:

``` ruby
gem 'rest-builder', :git => 'git://github.com/godfat/rest-builder.git',
                    :submodules => true
```

If you want to use pre-built middleware instead of rolling your own,
please checkout [rest-core][].

If you just want to use Facebook or Twitter clients, please take a look at
[rest-more][] which has a lot of clients built with rest-core.

## Basic Usage:

Use `RestBuilder::Builder` to build your own clients like `Rack::Builder` to
build your application. The client you built this way would be a class which
you could then make client instances from. This way, each instance could
carry different configuration, e.g. different cache time or timeout time.

``` ruby
require 'rest-builder'

YourClient = RestBuilder::Builder.client do
  # use ...
  # use ...
  # run ...
end
client = YourClient.new
client.get('http://example.com/') # make a request to http://example.com/
```

## Build Your Own Middleware:

### How We Pick the Default Value:

There are a number of ways to specify a default value, each with different
priorities. Suppose we have a middleware which remembers an integer:

``` ruby
class HP
  def self.members; [:hp]; end
  include RestBuilder::Middleware
  def call env, &k
    puts "HP: #{hp(env)}"
    app.call(env, &k)
  end
end
Mage = RestBuilder::Builder.client do
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

## Concurrent Requests with Futures:

You can also make concurrent requests easily:
(see "Advanced Concurrent HTTP Requests -- Embrace the Future" for detail)

``` ruby
a = [client.get('http://example.com/a'), client.get('http://example.com/b')]
puts "It's not blocking... but doing concurrent requests underneath"
p a # Here we want the values, so it blocks here
puts "DONE"
```

## Exception Handling for Futures:

Note that since the API call would only block whenever you're looking at
the response, it won't raise any exception at the time the API was called.
So if you want to block and handle the exception at the time API was called,
you would do something like this:

``` ruby
begin
  response = client.get('http://nonexist/').itself # itself is the point
  do_the_work(response)
rescue => e
  puts "Got an exception: #{e}"
end
```

The trick here is forcing the future immediately give you the exact response,
so that rest-builder could see the response and raise the exception. You can
call whatever methods on the future to force this behaviour, but since
`itself` is a method from `Kernel` (which is included in `Object`), it's
always available and would return the original value, so it is the easiest
method to be remembered and used.

If you know the response must be a string, then you can also use `to_s`.
Like this:

``` ruby
begin
  response = client.get('http://nonexist/').to_s
  do_the_work(response)
rescue => e
  puts "Got an exception: #{e}"
end
```

Or you can also do this:

``` ruby
begin
  response = client.get('http://nonexist/')
  response.class # simply force it to load
  do_the_work(response)
rescue => e
  puts "Got an exception: #{e}"
end
```

The point is simply making a method call to force it load, whatever method
should work.

## Concurrent Requests with Callbacks:

On the other hand, callback mode also available:

``` ruby
client.get('http://example.com/'){ |v| p v }
puts "It's not blocking... but doing concurrent requests underneath"
client.wait # we block here to wait for the request done
puts "DONE"
```

## Exception Handling for Callbacks:

What about exception handling in callback mode? You know that we cannot
raise any exception in the case of using a callback. So rest-builder would
pass the exception object into your callback. You can handle the exception
like this:

``` ruby
client.get('http://nonexist/') do |response|
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

## Thread Pool / Connection Pool

Underneath, rest-builder would spawn a thread for each request, freeing you
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

## Gracefully shutdown

To shutdown gracefully, consider shutdown the thread pool (if we're using it),
and wait for all requests for a given client. For example, we'll do this when
we're shutting down:

``` ruby
YourClient.shutdown
```

We could put them in `at_exit` callback like this:

``` ruby
at_exit do
  YourClient.shutdown
end
```

If you're using unicorn, you probably want to put that in the config.

## Random Asynchronous Tasks

Occasionally we might want to do some asynchronous tasks which could take
the advantage of the concurrency facilities inside rest-builder, for example,
using `wait` and `shutdown`. You could do this with `defer` for a particular
client. For example:

``` ruby
YourClient.defer do
  sleep(1)
  puts "Slow task done"
end

YourClient.wait
```

## Persistent connections (keep-alive connections)

Since we're using [httpclient][] by default now, we would reuse connections,
making it much faster for hitting the same host repeatedly.

## Streaming Requests

Suppose we want to POST a file, instead of trying to read all the contents
in memory and send them, we could stream it from the file system directly.

``` ruby
client.post('path', File.open('README.md'))
```

Basically, payloads could be any IO object. Check out
[RestBuilder::Payload](lib/rest-builder/payload.rb) for more information.

## Streaming Responses

This one is much harder then streaming requests, since all built-in
middleware actually assume the responses should be blocking and buffered.
Say, some JSON parser could not really parse from streams.

We solve this issue similarly to the way Rack solves it. That is, we hijack
the socket. This would be how we're doing:

``` ruby
sock = client.get('path', {}, RestBuilder::HIJACK => true)
p sock.read(10)
p sock.read(10)
p sock.read(10)
```

Of course, if we don't want to block in order to get the socket, we could
always use the callback form:

``` ruby
client.get('path', {}, RestBuilder::HIJACK => true) do |sock|
  p sock.read(10)
  p sock.read(10)
  p sock.read(10)
end
```

Note that since the socket would be put inside `RestBuilder::RESPONSE_SOCKET`
instead of `RestBuilder::RESPONSE_BODY`, not all middleware would handle the
socket. In the case of hijacking, `RestBuilder::RESPONSE_BODY` would always
be mapped to an empty string, as it does not make sense to store the response
in this case.

## SSE (Server-Sent Events)

Not only JavaScript could receive server-sent events, any languages could.
Doing so would establish a keep-alive connection to the server, and receive
data periodically. We'll take Firebase as an example:

If you are using Firebase, please consider [rest-firebase][] instead.

[rest-firebase]: https://github.com/CodementorIO/rest-firebase

``` ruby
require 'rest-builder'

# Streaming over 'users/tom.json'
cl = RestBuilder::Builder.client.new
ph = 'https://SampleChat.firebaseIO-demo.com/users/tom.json'
es = cl.event_source(ph, {}, # this is query, none here
                     RestBuilder::REQUEST_HEADERS =>
                       {'Accept' => 'text/event-stream'})

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
p cl.put(ph, '{"some":"data"}')
p cl.post(ph, '{"some":"other"}')
p cl.get(ph)
p cl.delete(ph)

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

## More Control with `request_full`:

You can also use `request_full` to retrieve everything including response
status, response headers, and also other rest-builder options. But since
using this interface is like using Rack directly, you have to build the env
manually. To help you build the env manually, everything has a default,
including the path.

``` ruby
client.request_full(RestBuilder::REQUEST_PATH =>
                      'http://example.com/')[RestBuilder::RESPONSE_BODY]
client.request_full(RestBuilder::REQUEST_PATH =>
                      'http://example.com/')[RestBuilder::RESPONSE_STATUS]
client.request_full(RestBuilder::REQUEST_PATH =>
                      'http://example.com/')[RestBuilder::RESPONSE_HEADERS]
# Headers are normalized with all upper cases and
# dashes are replaced by underscores.

# To make POST (or any other request methods) request:
client.request_full(RestBuilder::REQUEST_PATH   => 'http://example.com/',
                    RestBuilder::REQUEST_METHOD =>
                      :post)[RestBuilder::RESPONSE_STATUS] # 404
```

## Advanced Concurrent HTTP Requests -- Embrace the Future

### The Interface

There are a number of different ways to make concurrent requests in
rest-builder. They could be roughly categorized to two different forms.
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
client = YourClient.new
puts "httpclient with threads doing concurrent requests"
a = [client.get('http://example.com/a'), client.get('http://example.com/b')]
puts "It's not blocking... but doing concurrent requests underneath"
p a # Here we want the values, so it blocks here
puts "DONE"
```

And here's a corresponded version for using callbacks:

``` ruby
client = YourClient.new
puts "httpclient with threads doing concurrent requests"
client.get('http://example.com/a'){ |v|
         p v
       }.
       get('http://example.com/b'){ |v|
         p v
       }
puts "It's not blocking... but doing concurrent requests underneath"
client.wait # until all requests are done
puts "DONE"
```

You can pick whatever works for you.

[future]: http://en.wikipedia.org/wiki/Futures_and_promises

## Configure the underlying HTTP engine

Occasionally we might want to configure the underlying HTTP engine, which
for now is [httpclient][]. For example, we might not want to decompress
gzip automatically, (rest-core configures httpclient to request and
decompress gzip automatically). or we might want to skip verifying SSL
in some situation. (e.g. making requests against a self-signed testing server)

In such cases, we could use `config_engine` option to configure the underlying
engine. This could be set with request based, client instance based, or
client class based. Please refer to:
[How We Pick the Default Value](#how-we-pick-the-default-value),
except that there's no middleware for `config_engine`.

Here are some examples:

``` ruby
# class based:
def YourClient.default_config_engine
  lambda do |engine|
    # disable auto-gzip:
    engine.transparent_gzip_decompression = false

    # disable verifying SSL
    engine.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

# instance based:
client = YourClient.new(:config_engine => lambda do |engine|
  # disable auto-gzip:
  engine.transparent_gzip_decompression = false

  # disable verifying SSL
  engine.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
end)

# request based:
client.get('http://example.com/', {}, :config_engine => lambda do |engine|
  # disable auto-gzip:
  engine.transparent_gzip_decompression = false

  # disable verifying SSL
  engine.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
end)
```

As we stated in
[How We Pick the Default Value](#how-we-pick-the-default-value),
the priority here is:

0. request based
0. instance based
0. class based

## CONTRIBUTORS:

* Lin Jen-Shin (@godfat)

## LICENSE:

Apache License 2.0 (Apache-2.0)

Copyright (c) 2016-2019, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
