# frozen_string_literal: true

module GeneGenie
  # The outcome of an optimisation run (see Genie#run): the best parameters
  # found, their fitness, how much work the run did, and a per-generation
  # history of best and average fitness.
  # Fitness values are in the user's fitness space (un-negated for
  # minimisation runs).
  # @since 0.4.0
  class Result
    Stat = Struct.new(:generation, :best_fitness, :average_fitness)

    attr_reader :best, :best_fitness, :generations, :evaluations, :elapsed, :history

    def initialize(best:, best_fitness:, generations:, evaluations:, elapsed:, improved:, history:)
      @best = best
      @best_fitness = best_fitness
      @generations = generations
      @evaluations = evaluations
      @elapsed = elapsed
      @improved = improved
      @history = history
    end

    # Whether the run improved on the best fitness known before it started.
    def improved?
      @improved
    end
  end
end
