require 'logger'
require 'frenzy_bunnies/web'
require 'march_hare'

class FrenzyBunnies::Context
  attr_reader :queue_factory, :queue_publisher, :logger, :env, :opts,
              :error_handlers

  def initialize(opts={})
    @opts = opts
    @opts[:message_persistent] ||= false
    @opts[:host]               ||= 'localhost'
    @opts[:exchanges]          ||= 'frenzy_bunnies'
    @opts[:heartbeat]          ||= 5
    @opts[:web_host]           ||= 'localhost'
    @opts[:web_port]           ||= 11333
    @opts[:env]                ||= 'development'
    @opts[:web_threadfilter]   ||= /^pool-.*/

    @env    = @opts[:env]
    @logger = @opts[:logger] || Logger.new(STDOUT)
    params  = { host: @opts[:host], heartbeat_interval: @opts[:heartbeat] }

    (params[:username], params[:password] = @opts[:username], @opts[:password]) if @opts[:username] && @opts[:password]
    (params[:port] = @opts[:port]) if @opts[:port]

    params[:thread_pool_size] = (Java::JavaLang::Runtime.getRuntime.availableProcessors*6)
    # params[:executor_factory] = Proc.new { MarchHare::ThreadPools.dynamically_growing }

    @connection = MarchHare.connect(params)
    @connection.add_shutdown_listener(lambda { |cause| @logger.error("Disconnected: #{cause}"); stop;})

    @queue_factory   = FrenzyBunnies::QueueFactory.new(@connection, @opts[:exchanges])
    @queue_publisher = FrenzyBunnies::Publisher.new(@connection, @opts)

    @error_handlers  = @opts[:error_handlers] || []
  end

  def run(*klasses)
    @klasses = []
    klasses.each {|klass| klass.start(self); @klasses << klass}

    run_web_interface unless @opts[:disable_web_stats]
  end

  def run_web_interface
    if @web_interface.nil? || (@web_interface.is_a?(Thread) && !@web_interface.alive?)
      @web_interface = Thread.new do
        FrenzyBunnies::Web.run_with(@klasses, host: @opts[:web_host],
                                              port: @opts[:web_port],
                                              threadfilter: @opts[:web_threadfilter],
                                              logger: @logger)
      end
    else
      @logger.warn "[Web] There is alive interface instance in thread #{@web_interface.object_id}"
    end
  end

  def stop
    @klasses.each {|klass| klass.stop }
    stop_web_interface
  end

  def stop_web_interface
    if @web_interface.is_a?(Thread) && @web_interface.alive?
      if @web_interface.kill
        @web_interface = nil
      end
    end
  end

  # Pass exception to all handlers
  def handle_exception(ex, msg)
    @error_handlers.each do |handler|
      handler.call(ex, msg)
    end
  end

end

