# frozen_string_literal: true

module GeneGenie
  module Combiner
    # Creates new allele values by taking a (randomly) weighted average of
    # the two parent genes' values. Good for genes that represent numeric
    # scalar values, but not for genes representing discrete info.
    # Values are rounded to integers.
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
            weight = @random.rand
            [key, ((weight * value) + ((1 - weight) * second_gene_hashes[index][key])).round]
          end
        end
        Gene.new(information: new_information,
                 fitness_evaluator: first_gene.fitness_evaluator,
                 gene_combiner: self)
      end
    end
  end
end
