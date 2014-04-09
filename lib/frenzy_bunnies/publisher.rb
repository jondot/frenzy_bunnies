module FrenzyBunnies
  class Publisher

    def initialize(opts = {})
      @opts = opts
    end

    # publish(data, :routing_key => "resize")
    def publish(msg, exchange_name, routing={})
      @exchange_name = exchange_name
      ensure_connection! unless connected?
      @exchange.publish(msg, routing_key: routing[:routing_key])
    end

    private

    def ensure_connection!
      @conn = MarchHare.connect(host: @opts[:host], user: @opts[:username], password: @opts[:password])
      @ch   = @conn.create_channel
      # @exchange = MarchHare::Exchange.new(@ch,  @opts[:exchange], :type => :fanout, :durable=>true)
      @exchange = MarchHare::Exchange.new(@ch,  @exchange_name,  symbolize(@opts[:exchanges][@exchange_name]))
    end

    def connected?
      @conn && @conn.open?
    end

    def symbolize(opts)
      opts.inject({}){|h,(k,v)| h.merge({ k.to_sym => v}) }
    end
  end
end
