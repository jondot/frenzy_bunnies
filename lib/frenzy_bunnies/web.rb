require 'sinatra/base'
require 'json'

class FrenzyBunnies::Web < Sinatra::Base
  configure do
    # disable logging
    set :public_folder, File.expand_path('web/public', File.dirname(__FILE__))
  end

  before do
    content_type 'application/json'
  end

  not_found do
    'Cant find that, sorry.'
  end

  error do
  'Oops. There was an error - ' + env['sinatra.error'].name
  end

  get '/ping' do
    'ok'
  end

  get '/health' do
    settings.health_collector.collect.to_json
  end

  get '/stats' do
    jobs.map do |klass|
      { :name => klass.name,
        :stats => klass.jobs_stats }
    end.to_json
  end

  get '/' do
    redirect '/index.html'
  end

  def self.run_with(jobs, opts={})
    set :jobs, (jobs || [])
    set :health_collector, FrenzyBunnies::Health::Collector.new({:jvm => {:threadfilter => opts[:threadfilter]}})
    @logger = opts[:logger]
    @logger.info "* running web dashboard bound to #{opts[:host]} on port #{opts[:port]}."
    Rack::Handler::WEBrick.run self, :Host => opts[:host], :Port => opts[:port],  :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [nil, nil]
  end
  def jobs
    settings.jobs
  end
end
