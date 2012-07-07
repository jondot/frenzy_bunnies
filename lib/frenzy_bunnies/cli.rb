require 'thor'


class FrenzyBunnies::CLI < Thor
  BUNNIES =<<-EOF

    (\\___/)
    (='.'=)  Frenzy Bunnies!
    (")_(")  JRuby based workers on top of hot_bunnies

  EOF

  desc 'run', "run workers from a file"
  def start_workers(workerfile)

    require workerfile
    # enumerate all workers
    workers = []
    ObjectSpace.each_object(Class){|o| workers << o if o.ancestors.map(&:name).include? "FrenzyBunnies::Worker"}
    workers.uniq!
    
    puts BUNNIES

    c = FrenzyBunnies::Context.new
    c.logger.info "Discovered #{workers.inspect}"
    c.run *workers
    Signal.trap('INT') { c.stop; exit! }
  end
end
