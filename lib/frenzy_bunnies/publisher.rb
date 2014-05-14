module FrenzyBunnies
  class Publisher
    include Helpers::Utils

    def initialize(connection, opts = {})
      @connection = connection
      @opts = opts
    end

    # publish(data, :routing_key => "resize")
    def publish(msg, exchange_name, routing={})
      ch = @connection.create_channel
      exchange = MarchHare::Exchange.new(ch, exchange_name, symbolize(@opts[:exchanges][exchange_name]))      
      exchange.publish(msg, routing_key: routing[:routing_key], properties: { persistent: @opts[:message_persistent] }) if @connection.open?
      ch.close
    end

  end
end
