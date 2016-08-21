module GeneGenie
  # A NudgeMutator is very similar to a simple nutator, except that it will
  # only change a value by a small amount, rather than to any valid amount.
  # So, an allele with a rather specified in the template of 1..100, with a
  # current value of 50 might change in the range 45..55 instead of 1..100.
  # @since 0.2.0
  class NudgeMutator
    def initialize(template, mutation_rate = 0.04)
      @template = template
      @mutation_rate = mutation_rate * 1
    end

    def call(genes)
      genes.each_with_index do |hash, index|
        hash.each do |k, v|
          if rand < @mutation_rate
            nudge_max = (@template[index][k].size * 0.05).ceil
            hash[k] = rand(
              [@template[index][k].min, (v - nudge_max).floor].max..
              [@template[index][k].max, (v + nudge_max).ceil].min
            )
          end
        end
      end
      genes
    end
  end
end

