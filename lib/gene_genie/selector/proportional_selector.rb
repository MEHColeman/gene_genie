module GeneGenie
  # A proportional gene selection algorithm.
  # Genes are picked in proportion to thier normalised score.
  class ProportionalSelector
    def call(pool)
      [pick_one(pool), pick_one(pool)]
    end

    private

    def pick_one(pool)
      proportional_index = rand(total_normalised_fitness(pool))
      total = 0
      pool.genes.each_with_index do |gene, index|
        total += normalised_fitness(gene,pool)
        return gene if total >= proportional_index || index == (pool.size - 1)
      end
    end

    def total_normalised_fitness(pool)
      pool.genes.map { |gene| normalised_fitness(gene,pool) }.reduce(:+)
    end

    def normalised_fitness(gene,pool)
      gene.fitness -
        pool.worst_fitness + 1
    end
  end
end
