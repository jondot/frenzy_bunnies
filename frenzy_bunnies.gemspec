# -*- encoding: utf-8 -*-
require File.expand_path('../lib/frenzy_bunnies/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dotan Nahum"]
  gem.email         = ["jondotan@gmail.com"]
  gem.description   = %q{RabbitMQ JRuby based workers on top of hot_bunnies}
  gem.summary       = %q{RabbitMQ JRuby based workers on top of hot_bunnies}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "frenzy_bunnies"
  gem.require_paths = ["lib"]
  gem.version       = FrenzyBunnies::VERSION
  
  gem.add_runtime_dependency 'hot_bunnies', '>= 1.4.0.pre3'
  gem.add_runtime_dependency 'thor'
end
