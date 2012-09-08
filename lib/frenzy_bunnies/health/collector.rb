class FrenzyBunnies::Health::Collector
  def initialize(opts={})
    @providers = []
    Dir["#{File.dirname(__FILE__)}/providers/*.rb"].each do |f| 
      require f
      name = File.basename(f, '.*')
      provider_klass = FrenzyBunnies::Health::Providers.const_get(camelize name)
      @providers << provider_klass.new(opts[name.to_sym])
    end
  end

  def collect
    @providers.map{|p| p.report }.inject(:merge)
  end

  # real basic camelizer, beware!. meant to avoid including active-support here.
  def camelize(str)
    str.split('_').map {|s| s.capitalize}.join
  end
end

