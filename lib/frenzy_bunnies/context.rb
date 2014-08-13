require 'logger'
require 'frenzy_bunnies/web'

class FrenzyBunnies::Context
  attr_reader :queue_factory, :logger, :env, :opts

  def initialize(opts={})
    @opts = opts
    @opts[:host]     ||= 'localhost'
    @opts[:heartbeat] ||= 5
    @opts[:web_host] ||= 'localhost'
    @opts[:web_port] ||= 11333
    @opts[:web_threadfilter] ||= /^pool-.*/
    @opts[:env] ||= 'development'

    @env = @opts[:env]
    @logger = @opts[:logger] || Logger.new(STDOUT)
    params = {:host => @opts[:host], :heartbeat_interval => @opts[:heartbeat]}
    (params[:username], params[:password] = @opts[:username], @opts[:password]) if @opts[:username] && @opts[:password]
    (params[:port] = @opts[:port]) if @opts[:port]
    @connection = MarchHare.connect(params)
    @connection.add_shutdown_listener(lambda { |cause| @logger.error("Disconnected: #{cause}"); stop;})

    @queue_factory = FrenzyBunnies::QueueFactory.new(@connection)
  end

  def run(*klasses)
    @klasses = []
    klasses.each{|klass| klass.start(self); @klasses << klass}
    return nil if @opts[:disable_web_stats]
    Thread.new do
      FrenzyBunnies::Web.run_with(@klasses, :host => @opts[:web_host], :port => @opts[:web_port], :threadfilter => @opts[:web_threadfilter], :logger => @logger)
    end
  end

  def stop
    @klasses.each{|klass| klass.stop }
  end
end

