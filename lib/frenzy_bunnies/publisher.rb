module FrenzyBunnies
  class Publisher

    def initialize(opts = {})
      @opts = opts
    end

    # publish(data, :routing_key => "resize")
    def publish(msg, routing={})
      ensure_connection! unless connected?
      @exchange.publish(msg, routing_key: routing[:routing_key])
    end

    private

    def ensure_connection!
       binding.pry
      @conn = MarchHare.connect(:host => @opts[:host], :user => @opts[:username], :password => @opts[:password])
      @ch   = @conn.create_channel
      @exchange = MarchHare::Exchange.new(@ch,  @opts[:exchange], :type => :fanout, :durable=>true)
      # @x    = @ch.fanout("quality.fanout", :durable => true)
    end

    def connected?
      @conn && @conn.open?
    end
  end
end
