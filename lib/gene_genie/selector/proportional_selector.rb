module GeneGenie
  # A proportional gene selection algorithm.
  # Genes are picked in proportion to thier normalised score.
  class ProportionalSelector
    def call(pool)
      [pick_one(pool), pick_one(pool)]
    end

    private

    def pick_one(pool)
      proportional_index = rand(pool.total_normalised_fitness)
      total = 0
      pool.genes.each_with_index do |gene, index|
        total += gene.normalised_fitness(pool.worst_fitness)
        return gene if total >= proportional_index || index == (pool.size - 1)
      end
    end
  end
end
