# frozen_string_literal: true

module GeneGenie
  # Wraps a user-supplied fitness function, normalising the different ways
  # one can be supplied and configured:
  #
  # - the evaluator may implement +#fitness+ or be any +#call+-able
  #   (a lambda, proc or method object)
  # - +direction: :minimise+ negates scores internally, so the gene pool
  #   can always maximise
  # - +bare_template: true+ unwraps the internal array-of-hashes, so a user
  #   who supplied a plain Hash template receives a plain hash of values
  #
  # Also counts evaluations, for reporting in Result.
  # @since 0.4.0
  class FitnessAdapter
    DIRECTIONS = { maximise: :maximise, maximize: :maximise,
                   minimise: :minimise, minimize: :minimise }.freeze

    attr_reader :evaluations, :direction

    def initialize(evaluator, direction: :maximise, bare_template: false)
      @direction = DIRECTIONS[direction]
      raise ArgumentError, 'direction must be :maximise or :minimise' if @direction.nil?

      @callable = to_callable(evaluator)
      @bare_template = bare_template
      @evaluations = 0
    end

    def fitness(information)
      @evaluations += 1
      params = @bare_template ? information.first : information
      to_internal(@callable.call(params))
    end

    # Translate a fitness value from the pool's internal (always-maximising)
    # space back to the user's space.
    def to_user(fitness)
      @direction == :minimise ? -fitness : fitness
    end

    # Translate a fitness value from the user's space into the pool's
    # internal (always-maximising) space.
    def to_internal(fitness)
      @direction == :minimise ? -fitness : fitness
    end

    private

    def to_callable(evaluator)
      if evaluator.respond_to?(:fitness)
        ->(params) { evaluator.fitness(params) }
      elsif evaluator.respond_to?(:call)
        evaluator
      else
        raise ArgumentError, 'fitness evaluator must respond to #fitness or #call'
      end
    end
  end
end
