module GeneGenie
  module Combiner
    # Picks alleles from each Gene randomly
    class OnePointCombiner
      def call(gene_a, gene_b)
        if rand >= 0.5
          first_gene = gene_a
          second_gene = gene_b
        else
          first_gene = gene_b
          second_gene = gene_a
        end
        first_gene_hashes = first_gene.to_hashes
        second_gene_hashes = second_gene.to_hashes

        total_length = first_gene_hashes.map(&:size).reduce(:+)
        crossover_point = rand(0..(total_length - 1))

        count = 0
        new_information = first_gene_hashes.map.with_index do |part, index|
          new_hash = {}
          part.each do |k, v|
            new_hash[k] = (count >= crossover_point) ? second_gene_hashes[index][k] : v
            count += 1
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
