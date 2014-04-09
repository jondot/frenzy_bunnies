require 'hot_bunnies'
require 'timeout'

require "frenzy_bunnies/version"
require 'frenzy_bunnies/health'
require 'frenzy_bunnies/queue_factory'
require 'frenzy_bunnies/context'
require 'frenzy_bunnies/worker'
require 'frenzy_bunnies/web'
require 'frenzy_bunnies/publisher'

module FrenzyBunnies

  def self.publish(msg, exchange_name, routing)
    @publisher.publish(msg, exchange_name, routing)
  end

  def self.configure(opts={})
    setup_publisher(opts)
    FrenzyBunnies::Context.new(opts)
  end

private

  def self.setup_publisher(opts)
    @publisher ||= FrenzyBunnies::Publisher.new(opts)
  end

end