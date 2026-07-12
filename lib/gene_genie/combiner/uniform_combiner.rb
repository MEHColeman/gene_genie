# frozen_string_literal: true

module GeneGenie
  module Combiner
    # Uniform crossover: each child allele is picked from one of the two
    # parents with equal probability.
    class UniformCombiner
      # @param random [Random] source of randomness - pass a seeded instance
      #   for reproducible combination
      def initialize(random: Random.new)
        @random = random
      end

      def call(first_gene, second_gene)
        second_gene_hashes = second_gene.to_hashes
        new_information = first_gene.to_hashes.map.with_index do |part, index|
          part.to_h do |key, value|
            [key, @random.rand > 0.5 ? value : second_gene_hashes[index][key]]
          end
        end
        Gene.new(information: new_information,
                 fitness_evaluator: first_gene.fitness_evaluator,
                 gene_combiner: self)
      end
    end
  end
end
