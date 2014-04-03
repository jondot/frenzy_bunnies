require 'atomic'


module FrenzyBunnies::Worker
  import java.util.concurrent.Executors

  def ack!
    true
  end

  def work

  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def from_queue(q, opts={})
      @queue_name = q
      @queue_opts = opts
    end

    def start(context)
      @jobs_stats = { failed: Atomic.new(0), passed: Atomic.new(0) }
      @working_since = Time.now

      @logger = context.logger

      queue_name = "#{@queue_name}_#{context.env}"

      @queue_opts[:prefetch] ||= 10
      @queue_opts[:durable] ||= false
      @queue_opts[:timeout_job_after] ||=5

      if @queue_opts[:threads]
        @thread_pool = Executors.new_fixed_thread_pool(@queue_opts[:threads])
      else
        @thread_pool = Executors.new_cached_thread_pool
      end

      factory_options = filter_hash(@queue_opts, :exchange_options,
                                                 :queue_options,
                                                 :bind_options,
                                                 :durable,
                                                 :prefetch)

      q = context.queue_factory.build_queue(queue_name, factory_options)

      @s = q.subscribe(ack: true)

      say "#{@queue_opts[:threads] ? "#{@queue_opts[:threads]} threads " : ''}with #{@queue_opts[:prefetch]} prefetch on <#{queue_name}>."

      @s.each(blocking: false, executor: @thread_pool) do |h, msg|
        wkr = new

        work_block = Proc.new do |header, message|
          case wkr.method(:work).arity
          when 2
            wkr.work(header, message)
          when 1
            wkr.work(message)
          end
        end

        begin
          Timeout::timeout(@queue_opts[:timeout_job_after]) do
            if(work_block(h, msg))
              h.ack
              incr! :passed
            else
              h.reject
              incr! :failed
              error "REJECTED", msg
            end
          end
        rescue Timeout::Error
          h.reject
          incr! :failed
          error "TIMEOUT #{@queue_opts[:timeout_job_after]}s", msg
        rescue
          h.reject
          incr! :failed
          error "ERROR #{$!}", msg
        end
      end

      say "workers up."
    end

    def stop
      say "stopping"
      @thread_pool.shutdown_now
      say "pool shutdown"
      # @s.cancel  #for some reason when the channel socket is broken, this is holding the process up and we're zombie.
      say "stopped"
    end

    def queue_opts
      @queue_opts
    end

    def jobs_stats
      Hash[ @jobs_stats.map{ |k,v| [k, v.value] } ].merge({ since: @working_since.to_i })
    end
  private
    def say(text)
      @logger.info "[#{self.name}] #{text}"
    end

    def error(text, msg)
      @logger.error "[#{self.name}] #{text} <#{msg}>"
    end

    def incr!(what)
      @jobs_stats[what].update { |v| v + 1 }
    end

    def filter_hash(hash, *args)
      return nil if args.size == 0
      if args.size == 1
        args[0] = args[0].to_s if args[0].is_a?(Symbol)
        hash.select {|key| key.to_s.match(args.first) }
      else
        hash.select {|key| args.include?(key)}
      end
    end

  end
end

