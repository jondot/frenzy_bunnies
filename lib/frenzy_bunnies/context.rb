require 'logger'
require 'frenzy_bunnies/web'

class FrenzyBunnies::Context
  attr_reader :queue_factory, :logger, :env

  def initialize(opts={})
    @opts = opts
    @opts[:host]     ||= 'localhost'
    @opts[:exchange] ||= 'frenzy_bunnies'
    @opts[:heartbeat] ||= 5
    @opts[:web_host] ||= 'localhost'
    @opts[:web_port] ||= 11333
    @opts[:web_threadfilter] ||= /^pool-.*/
    @opts[:env] ||= 'development'

    @env = @opts[:env]
    @logger = @opts[:logger] || Logger.new(STDOUT)
    @connection = HotBunnies.connect(:host => @opts[:host], :heartbeat_interval => @opts[:heartbeat])
    @connection.add_shutdown_listener(lambda { |cause| @logger.error("Disconnected: #{cause}"); stop;})

    @queue_factory = FrenzyBunnies::QueueFactory.new(@connection, @opts[:exchange])
  end

  def run(*klasses)
    @klasses = []
    klasses.each{|klass| klass.start(self); @klasses << klass}
    Thread.new do
      FrenzyBunnies::Web.run_with(@klasses, :host => @opts[:web_host], :port => @opts[:web_port], :threadfilter => @opts[:web_threadfilter], :logger => @logger)
    end
  end

  def stop
    @klasses.each{|klass| klass.stop }
  end
end

