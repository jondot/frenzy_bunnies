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

      q = context.queue_factory.build_queue(queue_name, @queue_opts[:prefetch], @queue_opts[:durable])
      @s = q.subscribe(:ack => true)

      say "#{@queue_opts[:threads] ? "#{@queue_opts[:threads]} threads " : ''}with #{@queue_opts[:prefetch]} prefetch on <#{queue_name}>."

      @s.each(:blocking => false, :executor => @thread_pool) do |h, msg|
        wkr = new
        begin
          Timeout::timeout(@queue_opts[:timeout_job_after]) do
            if(wkr.work(msg))
              h.ack
            else
              h.reject
              error "REJECTED", msg
            end
          end
        rescue Timeout::Error
          h.reject
          error "TIMEOUT #{@queue_opts[:timeout_job_after]}s", msg
        rescue
          h.reject
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

    def say(text)
      @logger.info "[#{self.name}] #{text}"
    end
    
    def error(text, msg)
      @logger.error "[#{self.name}] #{text} <#{msg}>"
    end
  end
end

