# FrenzyBunnies

A lightweight JRuby based library backed by RabbitMQ and the very efficient `hot_bunnies` RabbitMQ driver for very fast and
efficient processing of RabbitMQ background jobs and messages.

Unlike other background job processing libraries, a Frenzy Bunnies worker is offering its work to a native JVM-based thread pool, where threads are allocated and cached.  

This firstly means the processing model isn't process-per-worker (saving memory) and it also isnt fixed-thread-per-worker based (saving memory even further).


## Quick Start

You basically just need to define a worker in its own class, and then
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

Running a worker with the command-line binary is easy

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

context definitions

## In Detail

### Tweaking Workers

worker definitions

running context definitions

### AMQP Queue Wireup


Add this line to your application's Gemfile:

    gem 'frenzy_bunnies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frenzy_bunnies

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
