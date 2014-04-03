class FrenzyBunnies::QueueFactory
  def initialize(connection, exchange)
    @connection = connection
    @exchange = exchange
  end

  def build_queue(name, prefetch, durable, routing_key)
    routing_key    ||= name
    channel          = @connection.create_channel
    channel.prefetch = prefetch

    exchange = channel.exchange(@exchange, type: :direct, durable: durable)

    queue    = channel.queue(name, durable: durable)
    queue.bind(exchange, routing_key: routing_key)
    queue
  end
end
