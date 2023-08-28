# frozen_string_literal: true

require File.expand_path('lib/ventable/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ["Konstantin Gredeskoul"]
  gem.email         = ["kigster@gmail.com"]
  gem.description   = 'Event/Observable design pattern in ruby'
  gem.summary       = 'Event/Observable design pattern in ruby'
  gem.homepage      = "https://github.com/kigster/ventable"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.name          = "ventable"
  gem.require_paths = ["lib"]
  gem.version       = Ventable::VERSION
  gem.metadata['rubygems_mfa_required'] = 'true'
end
