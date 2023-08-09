module GeneGenie
  # ProportionalSelector is a class that selects genes based on a proportional selection algorithm.
  # Genes are picked in proportion to their normalized score.
  class ProportionalSelector
    # Calls the proportional selector on a pool of genes, returning two selected genes.
    #
    # @param pool [Object] the pool of genes containing methods:
    #                      - +total_normalised_fitness+ that returns the total normalized fitness.
    #                      - +genes+ that returns an array of genes.
    #                      - +worst_fitness+ that returns the worst fitness score in the pool.
    #                      - +size+ that returns the size of the pool.
    # @return [Array<Object>] an array containing two selected genes.
    def call(pool)
      [pick_one(pool), pick_one(pool)]
    end

    private

    # Picks one gene from the pool using proportional selection.
    #
    # @param pool [Object] the pool of genes containing methods:
    #                      - +total_normalised_fitness+ that returns the total normalized fitness.
    #                      - +genes+ that returns an array of genes.
    #                      - +worst_fitness+ that returns the worst fitness score in the pool.
    #                      - +size+ that returns the size of the pool.
    # @return [Object] the selected gene.
    # @note This method assumes that the gene object in the pool responds to +normalised_fitness(worst_fitness)+.
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
