require 'rubygems'
require 'march_hare'




connection = MarchHare.connect(:host => 'localhost')
channel = connection.create_channel
channel.prefetch = 10

exchange = channel.exchange('frenzy_bunnies', :type => :direct, :durable => true)



100_000.times do |i|
  exchange.publish("hello world! #{i}", :routing_key => 'new.feeds')
end
puts "done"


