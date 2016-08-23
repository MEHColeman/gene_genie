module GeneGenie
  module Combiner
    # Creates new allele value by creating a (random) weighted
    # average of the two parent genes. Good for genes that represent numeric
    # scalar values, but not for genes representing discrete info.
    class WeightedAverageCombiner
      def call(first_gene, second_gene)
        first_gene_hashes = first_gene.to_hashes
        second_gene_hashes = second_gene.to_hashes
        new_information = first_gene_hashes.map.with_index do |part, index|
          new_hash = {}
          part.each do |k, v|
            p_first = rand(0.0..100.0)
            p_second = 100 - p_first
            new_hash[k] = (((p_first * v) +
                            (p_second * second_gene_hashes[index][k]))/100).round
          end
          new_hash
        end
        Gene.new(information: new_information,
                 fitness_evaluator: first_gene.fitness_evaluator,
                 gene_combiner: self)
      end
    end
  end
end
