#require 'simplecov'
#SimpleCov.start if ENV["COVERAGE"]

require 'minitest/autorun'



require 'rr'


class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end


require 'thor'
# This is to silence the 'task' warning for the mocks.
#
class Thor
  class << self
    def create_task(meth) #:nodoc:
      if @usage && @desc
        base_class = @hide ? Thor::HiddenTask : Thor::Task
        tasks[meth] = base_class.new(meth, @desc, @long_desc, @usage, method_options)
        @usage, @desc, @long_desc, @method_options, @hide = nil
        true
      elsif self.all_tasks[meth] || meth == "method_missing"
        true
      else
        false
      end
    end
  end
end

