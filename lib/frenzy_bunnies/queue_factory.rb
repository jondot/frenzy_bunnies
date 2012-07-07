class FrenzyBunnies::QueueFactory
  def initialize(connection, exchange)
    @connection = connection
    @exchange = exchange
  end

  def build_queue(name, prefetch, durable)
    channel = @connection.create_channel
    channel.prefetch = prefetch

    exchange = channel.exchange(@exchange, :type => :direct, :durable => durable)

    queue = channel.queue(name)
    queue.bind(exchange, :routing_key => name)
    queue
  end
end
