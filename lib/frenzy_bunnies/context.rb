require 'logger'

class FrenzyBunnies::Context
  attr_reader :queue_factory, :logger

  def initialize(opts={})
    @opts = opts
    @opts[:host]     ||= 'localhost'
    @opts[:exchange] ||= 'frenzy_bunnies'
    @opts[:heartbeat] ||= 5
    @logger = @opts[:logger] || Logger.new(STDOUT)
    @connection = HotBunnies.connect(:host => @opts[:host], :heartbeat_interval => @opts[:heartbeat])
    @connection.add_shutdown_listener(lambda { |cause| @logger.error("Disconnected: #{cause}"); stop;})

    @queue_factory = FrenzyBunnies::QueueFactory.new(@connection, @opts[:exchange])
  end

  def run(*klasses)
    @klasses = []
    klasses.each{|klass| klass.start(self); @klasses << klass}
  end

  def stop
    @klasses.each{|klass| klass.stop }
  end
end

