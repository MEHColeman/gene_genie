# frozen_string_literal: true

require_relative 'gene'
require_relative 'combiner/one_point_combiner'

module GeneGenie
  # GeneFactory
  # This is a helper class that will create a specified number of genes, given
  # a template.
  # The default implementation will produce random genes, but other approaches
  # could be taken.
  class GeneFactory
    # @param random [Random] source of randomness - pass a seeded instance
    #   for reproducible gene creation
    def initialize(template, fitness_evaluator, gene_combiner = nil, random: Random.new)
      @template = template.is_a?(Hash) ? [template] : template
      @fitness_evaluator = fitness_evaluator
      @random = random
      @combiner = gene_combiner || Combiner::OnePointCombiner.new(random:)
    end

    def create(size = 1)
      Array.new(size) { create_gene_from_template }
    end

    private

    def create_gene_from_template
      gene_array = @template.map do |part|
        create_hash_from_template_part(part)
      end
      Gene.new(information: gene_array,
               fitness_evaluator: @fitness_evaluator,
               gene_combiner: @combiner)
    end

    def create_hash_from_template_part(part)
      part.transform_values { |options| sample_value(options) }
    end

    def sample_value(options)
      options.is_a?(Array) ? options.sample(random: @random) : @random.rand(options)
    end
  end
end
