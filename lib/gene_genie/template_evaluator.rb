# frozen_string_literal: true

module GeneGenie
  # A Template Evaluator provides certain analysis and useful information
  # about templates.
  # A template is always treated internally as an Array of Hashes. Each
  # value in a hash describes an allele's options: an integer range, a
  # float range (treated as continuous), or an array of choices.
  # @since 0.0.2
  class TemplateEvaluator
    # Float ranges are continuous, so they have no real permutation count;
    # this nominal count stands in for one when sizing pools.
    CONTINUOUS_OPTION_COUNT = 1000

    def initialize(template)
      @template = template.is_a?(Hash) ? [template] : template
    end

    def permutations
      @permutations ||= @template.map do |hash|
        hash.map { |_, options| option_count(options) }.reduce(:*)
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
      hash_under_test = [hash_under_test] if hash_under_test.is_a?(Hash)
      @template.each_with_index do |part, index|
        part.each do |key, options|
          value = hash_under_test[index][key]
          return false if value.nil?
          return false unless covers?(options, value)
        end
      end
      true
    rescue StandardError
      false
    end

    private

    def option_count(options)
      case options
      when Array
        options.size
      when Range
        continuous?(options) ? CONTINUOUS_OPTION_COUNT : options.size
      else
        raise ArgumentError, "unsupported template options: #{options.inspect}"
      end
    end

    def continuous?(range)
      range.begin.is_a?(Float) || range.end.is_a?(Float)
    end

    def covers?(options, value)
      options.is_a?(Array) ? options.include?(value) : options.cover?(value)
    end
  end
end
