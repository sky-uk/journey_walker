# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'journey_walker/version'

Gem::Specification.new do |spec|
  spec.name          = 'journey_walker'
  spec.version       = JourneyWalker::VERSION
  spec.authors       = ['Gareth Smyth']

  spec.summary       = 'Journey Walker allows data driven wizard style journeys to be created and managed.'
  spec.homepage      = 'https://github.com/gareth-smyth/journey_walker/wiki'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('lib/**/*') + %w(LICENSE README.md)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'r18n-core'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
