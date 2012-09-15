# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ventable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Konstantin Gredeskoul"]
  gem.email         = ["kigster@gmail.com"]
  gem.description   = %q{Event/Observable pattern with various options}
  gem.summary       = %q{Event/Observable support gem for plain ruby}
  gem.homepage      = "https://github.com/kigster/ventable"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ventable"
  gem.require_paths = ["lib"]
  gem.version       = Ventable::VERSION

  gem.add_development_dependency "rspec", "~> 2.11.0"
  gem.add_development_dependency "rspec-mocks", "~> 2.11.0"
end
