require 'logger'

class FrenzyBunnies::Context
  attr_reader :queue_factory, :logger

  def initialize(opts={})
    @opts = opts
    @opts[:host]     ||= 'localhost'
    @opts[:exchange] ||= 'frenzy_bunnies'
    @logger = @opts[:logger] || Logger.new(STDOUT)
    @connection = HotBunnies.connect(:host => @opts[:host])
    @connection.add_shutdown_listener(lambda { |cause| puts cause; stop; sleep(10); start;})

    @queue_factory = FrenzyBunnies::QueueFactory.new(@connection, @opts[:exchange])
    @klasses = []
  end

  def run(*klasses)
    klasses.each{|klass| klass.start(self); @klasses << klass}
  end

  def stop
    @klasses.each{|klass| klass.stop }
  end
end

