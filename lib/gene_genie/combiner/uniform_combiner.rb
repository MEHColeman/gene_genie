module GeneGenie
  module Combiner
    # Picks alleles from each Gene randomly
    class UniformCombiner
      def call(first_gene, second_gene)
        first_gene_hashes = first_gene.to_hashes
        second_gene_hashes = second_gene.to_hashes
        new_information = first_gene_hashes.map.with_index do |part, index|
          new_hash = {}
          part.each do |k, v|
            new_hash[k] = (rand > 0.5) ? v : second_gene_hashes[index][k]
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
