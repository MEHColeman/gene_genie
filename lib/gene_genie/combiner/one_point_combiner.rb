# frozen_string_literal: true

module GeneGenie
  module Combiner
    # Classic one-point crossover: child alleles are copied from the first
    # parent up to a randomly chosen crossover point, and from the second
    # parent after it. Which parent comes first is decided by a coin flip.
    class OnePointCombiner
      # @param random [Random] source of randomness - pass a seeded instance
      #   for reproducible combination
      def initialize(random: Random.new)
        @random = random
      end

      def call(gene_a, gene_b)
        first_gene, second_gene = @random.rand >= 0.5 ? [gene_a, gene_b] : [gene_b, gene_a]
        first_gene_hashes = first_gene.to_hashes
        second_gene_hashes = second_gene.to_hashes

        total_length = first_gene_hashes.sum(&:size)
        crossover_point = @random.rand(0..(total_length - 1))

        count = 0
        new_information = first_gene_hashes.map.with_index do |part, index|
          part.to_h do |key, value|
            allele = count >= crossover_point ? second_gene_hashes[index][key] : value
            count += 1
            [key, allele]
          end
        end
        Gene.new(information: new_information,
                 fitness_evaluator: first_gene.fitness_evaluator,
                 gene_combiner: self)
      end
    end
  end
end
