# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gene_genie/version'

Gem::Specification.new do |spec|
  spec.name          = 'gene_genie'
  spec.version       = GeneGenie::VERSION
  spec.authors       = ['Mark Coleman']
  spec.email         = ['m@rkcoleman.co.uk']
  spec.summary       = %q{Genetic algorithm optimisation gem}
  spec.description   = %q{Optimise anything that responds to 'fitness' and takes a hash}
  spec.homepage      = 'https://github.com/MEHColeman/gene_genie'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>=2.0.0'

  spec.files         = Dir.glob("{lib}/**/*") + ['README.md']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
