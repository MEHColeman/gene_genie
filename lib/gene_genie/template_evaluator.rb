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
      @permutations ||= @template.map { |hash|
        hash.map { |_, v| v.size }.reduce(:*)
      }.reduce(:*)
    end

    # Suggests a recommended GenePool size.
    # returns a minimum of 6 unless the total number of permutations
    # is below that.
    # Otherwise, returns 1/1000th of the number of permutations up to a
    # maximum of 20000
    def recommended_size
      [
        [((Math.log(permutations))**2).ceil, 20000].min,
        [6, permutations].min,
        3
      ].max
    end

    # Verifies that the given hash conforms to the constraints specified in the
    # hash template
    def hash_valid?(hash_under_test)
      begin
        @template.each_with_index do |h, index|
          h.each do |k, v|
            return false unless hash_under_test[index][k]
            return false unless hash_under_test[index][k] >= v.min
            return false unless hash_under_test[index][k] <= v.max
          end
        end
      rescue
        return false
      end
      return true
    end
  end
end
