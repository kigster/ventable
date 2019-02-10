# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ventable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors     = ['Konstantin Gredeskoul']
  gem.email       = ['kigster@gmail.com']
  gem.description = %q{Event/Observable design pattern in ruby}
  gem.summary     = %q{Event/Observable design pattern in ruby}
  gem.homepage    = 'https://github.com/kigster/ventable'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'ventable'
  gem.require_paths = ['lib']
  gem.version       = Ventable::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'rspec-mocks'
  gem.add_development_dependency 'guard-rspec'
end
