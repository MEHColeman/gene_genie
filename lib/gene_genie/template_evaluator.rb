# frozen_string_literal: true

module GeneGenie
  # A Template Evaluator provides certain analysis and useful information
  # about templates.
  # A template is always treated internally as an Array of Hashes.
  # @since 0.0.2
  class TemplateEvaluator
    def initialize(template)
      @template = template
    end

    def permutations
      @permutations ||= @template.map do |hash|
        hash.map { |_, v| v.size }.reduce(:*)
      end.reduce(:*)
    end

    # Suggests a recommended GenePool size:
    # the square of the natural log of the total number of permutations,
    # clamped to a maximum of 20,000 and a minimum of 6 (or the number of
    # permutations itself when even that is lower, with an absolute floor
    # of 3).
    def recommended_size
      [
        [(Math.log(permutations)**2).ceil, 20_000].min,
        [6, permutations].min,
        3
      ].max
    end

    # Verifies that the given hash conforms to the constraints specified in
    # the hash template
    def hash_valid?(hash_under_test)
      @template.each_with_index do |part, index|
        part.each do |key, range|
          value = hash_under_test[index][key]
          return false unless value
          return false unless value >= range.min
          return false unless value <= range.max
        end
      end
      true
    rescue StandardError
      false
    end
  end
end
