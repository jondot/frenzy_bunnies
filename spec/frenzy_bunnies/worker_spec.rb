require_relative '../spec_helper'
require 'frenzy_bunnies'

class DummyWorker
  include FrenzyBunnies::Worker
  from_queue 'new.feeds'

  def work(msg)
  end
end

class CustomWorker
  include FrenzyBunnies::Worker
  from_queue 'new.feeds', :prefetch => 20, :durable => true, :timeout_job_after => 13, :threads => 25

  def work(msg)
  end
end

def with_test_queuefactory(ctx, ack=true, msg=nil, nowork=false)
  qf = Object.new
  q = Object.new
  s = Object.new
  hdr = Object.new
  mock(qf).build_queue(anything, anything) { q }
  mock(q).subscribe(anything){ s }

  mock(s).each(anything) { |h,b| b.call(hdr, msg) unless nowork }
  mock(hdr).ack{true} if !nowork && ack
  mock(hdr).reject{true} if !nowork && !ack

  mock(ctx).queue_factory { qf } # should return our own
end

describe FrenzyBunnies::Worker do
  it "should start with a clean slate" do
    # check stats, default configuration
    ctx = FrenzyBunnies::Context.new(:logger=> Logger.new(nil))
    with_test_queuefactory(ctx, nil, nil, true)


    DummyWorker.start(ctx)
    DummyWorker.jobs_stats[:failed].must_equal 0
    DummyWorker.jobs_stats[:passed].must_equal 0
    q = DummyWorker.queue_opts
    q.must_equal({:prefetch=>10, :durable=>false, :timeout_job_after=>5})

  end
  it "should respond to configuration tweaks" do
    # check that all params are changed
    ctx = FrenzyBunnies::Context.new(:logger=> Logger.new(nil))
    with_test_queuefactory(ctx, nil, nil, true)

    CustomWorker.start(ctx)
    CustomWorker.jobs_stats[:failed].must_equal 0
    CustomWorker.jobs_stats[:passed].must_equal 0
    q = CustomWorker.queue_opts
    q.must_equal({:prefetch=>20, :durable=>true, :timeout_job_after=>13, :threads=>25})
  end
  it "should stop when asked to" do
    # validate that a worker stops
    # check stats, default configuration
    ctx = FrenzyBunnies::Context.new(:logger=> Logger.new(nil))
    with_test_queuefactory(ctx, nil, nil, true)


    DummyWorker.start(ctx)
    DummyWorker.stop
  end
  it "should be passed a message to work on" do
    ctx = FrenzyBunnies::Context.new(:logger=> Logger.new(nil))
    with_test_queuefactory(ctx, true, "work!")

    any_instance_of(DummyWorker){ |w| mock(w).work("work!"){ true } }
    DummyWorker.start(ctx)
  end
  it "should acknowledge a unit of work when worker succeeds" do
    ctx = FrenzyBunnies::Context.new(:logger=> Logger.new(nil))
    with_test_queuefactory(ctx)

    any_instance_of(DummyWorker){ |w| mock(w).work(anything){ true } }
    DummyWorker.start(ctx)
    DummyWorker.jobs_stats[:passed].must_equal 1
    DummyWorker.jobs_stats[:failed].must_equal 0
  end
  it "should reject a unit of work when worker fails" do
    ctx = FrenzyBunnies::Context.new(:logger=> Logger.new(nil))
    with_test_queuefactory(ctx,false)

    any_instance_of(DummyWorker){ |w| mock(w).work(anything){ false } }
    mock(DummyWorker).error(anything, anything){ |text, _| text.must_match(/^REJECTED/) }
    DummyWorker.start(ctx)
    DummyWorker.jobs_stats[:failed].must_equal 1
    DummyWorker.jobs_stats[:passed].must_equal 0
  end
  it "should reject a unit of work when worker times out" do
    ctx = FrenzyBunnies::Context.new(:logger=> Logger.new(nil))
    with_test_queuefactory(ctx,false)
    DummyWorker.queue_opts[:timeout_job_after] = 1
    any_instance_of(DummyWorker){ |w| mock(w).work(anything){ sleep(2) }}
    mock(DummyWorker).error(anything, anything){ |text, _| text.must_match(/^TIMEOUT/) }
    DummyWorker.start(ctx)
    DummyWorker.jobs_stats[:failed].must_equal 1
    DummyWorker.jobs_stats[:passed].must_equal 0
    DummyWorker.queue_opts[:timeout_job_after] = 5
  end
  it "should reject a unit of work when worker fails exceptionally" do
    ctx = FrenzyBunnies::Context.new(:logger=> Logger.new(nil))
    with_test_queuefactory(ctx,false)

    any_instance_of(DummyWorker){ |w| mock(w).work(anything){ throw :error } }
    mock(DummyWorker).error(anything, anything){ |text, _| text.must_match(/^ERROR/) }
    DummyWorker.start(ctx)
    DummyWorker.jobs_stats[:failed].must_equal 1
    DummyWorker.jobs_stats[:passed].must_equal 0
  end
end
