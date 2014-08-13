class FrenzyBunnies::QueueFactory
  def initialize(connection)
    @connection = connection
  end

  def build_queue(name, options)
    exchange_name = options[:exchange] || 'frenzy_bunnies'
    exchange_type = options[:exchange_type] || :direct
    routing_key = options[:routing_key] || name
    durable = options[:durable]
    prefetch = options[:prefetch]

    channel = @connection.create_channel
    channel.prefetch = prefetch

    exchange = channel.exchange(exchange_name, :type => exchange_type, :durable => durable)

    queue = channel.queue(name, :durable => durable)
    queue.bind(exchange, :routing_key => routing_key)
    queue
  end
end
