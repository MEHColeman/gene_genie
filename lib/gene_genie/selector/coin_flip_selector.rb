module GeneGenie
  # A simple gene selection algorithm.
  # Genes are ordered by score.
  # Effectively, a loaded coin is tossed. If it's heads, the top gene is
  # selected, otherwise, continue down the list until a head comes up.
  # The coin is loaded, so that there is a reasonable spread throughout the
  # gene population, but the better the gene, the more likely it is to turn up.
  class CoinFlipSelector
    def call(pool)
      # a very simple selection - pick by sorted order
      # pick two different genes
      selectees = pool.sort.reverse
      first, second = nil, nil
      probability = [((1.0 / pool.size) * 3), 0.8].min
      while !first || !second do
        selectees.each do |s|
          if rand < probability
            selectees.delete(s)
            if !first
              first = s
              break
            else
              second = s
            end
          end
        end
      end
      [first, second]
    end
  end
end
