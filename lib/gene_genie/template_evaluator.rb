module GeneGenie
  # A Template Evaluator provides certain analysis and useful information
  # about templates
  # @since 0.0.2
  class TemplateEvaluator
    def initialize(template)
      @template = template
    end

    def permutations
      @permutations ||= @template.map { |hash|
        hash.map { |_, v| v.size }.reduce(:*)
      }.reduce(:*)
    end

    # returns a minimum of 10 unless the total number of permutations
    # is below that
    # otherwise, returns 1/1000th of the number of permutations up to a
    # maximum of 1000
    def recommended_size
      [
        [(permutations / 100_000), 5000].min,
        [10, permutations].min,
      ].max
    end
  end
end
