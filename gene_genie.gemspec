# frozen_string_literal: true

require_relative 'lib/gene_genie/version'

Gem::Specification.new do |spec|
  spec.name          = 'gene_genie'
  spec.version       = GeneGenie::VERSION
  spec.authors       = ['Mark Coleman']
  spec.email         = ['m@rkcoleman.co.uk']
  spec.summary       = 'Genetic algorithm optimisation gem'
  spec.description   = "Optimise anything that responds to 'fitness' and takes a hash"
  spec.homepage      = 'https://github.com/MEHColeman/gene_genie'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/master/CHANGELOG.md",
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir.glob('lib/**/*.rb') + %w[README.md CHANGELOG.md LICENSE.txt]
  spec.require_paths = ['lib']
end
