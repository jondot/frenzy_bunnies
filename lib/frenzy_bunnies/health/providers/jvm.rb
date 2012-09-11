require 'java'

java_import 'java.lang.management.ManagementFactory'

class FrenzyBunnies::Health::Providers::Jvm
  def initialize(opts)
    # init beans
    @opts = opts
    @memorymx = ManagementFactory.memory_mx_bean
    @threadmx = ManagementFactory.thread_mx_bean
    @threadmx_thread_info = @threadmx.java_method :getThreadInfo, [Java::long, Java::int]
    @runtimemx = ManagementFactory.runtime_mx_bean
  end

  def report
    h = {}
    heap = @memorymx.heap_memory_usage
    h[:heap_usage_used_bytes] = heap.used
    h[:heap_usage_max_bytes] = heap.max
    h[:heap_usage_committed_bytes] = heap.committed
    h[:heap_usage_human] = heap.to_s

    h[:jvm_uptime_ms] = @runtimemx.uptime

    ids = @threadmx.all_thread_ids
    h[:threads] = ids.map do |id|
      info = @threadmx_thread_info.call(id, 10)
      if info && info.thread_name =~ @opts[:threadfilter]
        {
          :name => info.thread_name,
          :stack_trace => info.stack_trace.to_a.inject([]){|a,s| a<<s.to_s },
          :state => info.thread_state.to_s
        }
      else
        nil
      end
    end.compact

    ids.map{|i| @threadmx_thread_info.call(i, 10) }.compact.map {|inf| inf.stack_trace.to_a.inject([]){|a,s| a<<s.to_s }}
    
    h
  end
end
