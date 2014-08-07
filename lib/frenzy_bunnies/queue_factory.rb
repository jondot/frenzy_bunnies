class FrenzyBunnies::QueueFactory
  def initialize(connection, exchange)
    @connection = connection
    @exchange = exchange
  end

  def build_queue(name, options)
    durable = options[:durable]
    prefetch = options[:prefetch]
    type = options[:type] || :direct
    routing_key = options[:routing_key] || name

    channel = @connection.create_channel
    channel.prefetch = prefetch

    exchange = channel.exchange(@exchange, :type => type, :durable => durable)

    queue = channel.queue(name, :durable => durable)
    queue.bind(exchange, :routing_key => routing_key)
    queue
  end
end
