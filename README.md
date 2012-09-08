# FrenzyBunnies

A lightweight JRuby based library backed by RabbitMQ and the very efficient `hot_bunnies` RabbitMQ driver for very fast and
efficient processing of RabbitMQ background jobs and messages.

Unlike other background job processing libraries, a Frenzy Bunnies worker is offering its work to a native JVM-based thread pool, where threads are allocated and cached.  

This firstly means the processing model isn't process-per-worker (saving memory) and it also isnt fixed-thread-per-worker based (saving memory even further).

RabbitMQ is a really awesome queue solution for background jobs as well as more real-time messaging processing. Within its strengths are its [performance](http://www.rabbitmq.com/blog/2012/04/17/rabbitmq-performance-measurements-part-1/), portability - [almost every worthy server-side language and platform](http://www.rabbitmq.com/devtools.html) has a RabbitMQ driver and you're not limited to process on a single platform, and high-availability out of the box (as opposed to Redis, although [Sentinel](http://redis.io/topics/sentinel-spec) is quite a progress - hurray!).  


Here are [great background slides](https://speakerdeck.com/u/hungryblank/p/rails-underground-2009-rabbitmq)  given by Paolo Negri over Rails Underground 2009 about [RabbitMQ](http://www.rabbitmq.com/).

## Quick Start

Add this line to your application's Gemfile:

    gem 'frenzy_bunnies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frenzy_bunnies

Then, you basically just need to define a worker in its own class, and then
decide if you want to use the Frenzy Bunnies runner
`frenzy_bunnies` to run it, or do it programmatically via the
`FrenzyBunnies::Context` API.

```ruby
class FeedWorker
  include FrenzyBunnies::Worker
  from_queue 'new.feeds', :prefetch => 20, :threads => 13, :durable => true

  def work(msg)
    puts msg
    ack!
  end
end
```

You indicate that a class is a worker by `include
FrenzyBunnies::Worker`. Set up a queue with `from_queue` and implement a
`work(msg)` method. 

You should indicate successful processing with
`ack!`, otherwise it will be rejected and lost (per RabbitMQ semantics,
in future versions, they'll add a feature where rejected messages goes
to an error queue).

### Running with CLI

Running a worker with the command-line executable is easy

    $ frenzy_bunnies start_workers worker_file.rb

Where `worker_file.rb` is a file containing all of your worker(s)
definition. FrenzyBunnies will require the file and immediately start
handing work to your workers.

### Running Programatically

Assuming that workers are already `require`d in your code, their classes
should be visible by the moment you write this code:

```ruby
f = FrenzyBunnies::Context.new
f.run FeedWorker,FeedDownloader
```

Which will run your workers immediately.


## Web Dashboard

When FrenzyBunnies run, it will automatically create a web dashboard for you, on `localhost:11333` by default.

`image`

Changing the bound address is easy to do through the many options you can pass to the running `Context`:

```ruby
f = FrenzyBunnies::Context.new :web_host=>'0.0.0.0', :web_port=>11222
```


context definitions

## In Detail

### Worker Configuration

say `from_queue 'queue_name'` and pass any of these options:

```ruby
:prefetch  # default 10. number of messages to prefetch each time
:durable   # default false. durability of the queue
:timeout_job_after # default 5. reject the message if not processed for number of seconds
:threads  # default none. number of threads in the threadpool. leave empty to let the threadpool manage it.
```


### General Configuration

Global / running configuration can be set through the running context `FrenzyBunnies::Context`, pass any of these as options (shown with defaults).

```ruby
:host       # default 'localhost'
:exchange   # default 'frenzy_bunnies'
:heartbeat  # default 5
:web_host   # default 'localhost'
:web_port   # default 11333
:web_threadfilter # default /^pool-.*/
:env        # default ''
```


Example:

```ruby
FrenzyBunnies::Context.new :exchange=> 'foo'
```

### AMQP Queue Wiring Under the Hood

If you're interested with the mechanics, in order to mimic a background-job / work-queue 
semantics, the following is the AMQP wireup used within this library:

* Durable per configuration
* The exchange is created and named by default `frenzy_bunnies`
* Each worker is bound to an AMQP queue named `my_queue`_`environment` with the environment postfix appended automatically.
* The routing key on the exchange is of the same name and bound to the queue.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

