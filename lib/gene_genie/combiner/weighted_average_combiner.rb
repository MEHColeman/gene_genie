# frozen_string_literal: true

module GeneGenie
  module Combiner
    # Creates new allele values by taking a (randomly) weighted average of
    # the two parent genes' values. Good for genes that represent numeric
    # scalar values, but not for genes representing discrete info.
    # Integer alleles stay integers (the average is rounded); float alleles
    # keep their precision.
    class WeightedAverageCombiner
      # @param random [Random] source of randomness - pass a seeded instance
      #   for reproducible combination
      def initialize(random: Random.new)
        @random = random
      end

      def call(first_gene, second_gene)
        second_gene_hashes = second_gene.to_hashes
        new_information = first_gene.to_hashes.map.with_index do |part, index|
          part.to_h do |key, value|
            other = second_gene_hashes[index][key]
            average = (@random.rand * (value - other)) + other
            [key, value.is_a?(Integer) && other.is_a?(Integer) ? average.round : average]
          end
        end
        Gene.new(information: new_information,
                 fitness_evaluator: first_gene.fitness_evaluator,
                 gene_combiner: self)
      end
    end
  end
end
