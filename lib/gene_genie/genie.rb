# frozen_string_literal: true

require_relative 'gene_pool'
require_relative 'fitness_adapter'
require_relative 'termination'
require_relative 'result'
require_relative 'listener/logging_listener'

# Namespace for GeneGenie genetic algorithm optimisation gem
# @since 0.0.1
module GeneGenie
  # Top level, basic interface for GA optimisation.
  # Genie will attempt to optimise based on best-guess defaults if none are
  # provided.
  # Genie is basically a wrapper around GenePool that lets you get going as
  # quickly as possible by providing a reasonable set of defaults.
  # For more control and customisation, go straight to using GenePool.
  # @since 0.0.1
  class Genie
    # Used when no termination criteria are given: evolve at most
    # DEFAULT_MAX_GENERATIONS generations, stopping early once the best
    # fitness has not improved for STAGNATION_PATIENCE consecutive
    # generations.
    DEFAULT_MAX_GENERATIONS = 100
    STAGNATION_PATIENCE = 15

    attr_reader :gene_pool

    # @param template [Hash, Array<Hash>] the variables to optimise, with
    #   their possible values: integer ranges, float ranges, or arrays of
    #   choices
    # @param fitness_evaluator [#fitness, #call, nil] scores a set of
    #   values; alternatively supply the fitness function as a block
    # @param seed [Integer, nil] seed for the random number generator - pass
    #   a value to make the optimisation run reproducible
    # @param direction [Symbol] :maximise (default) or :minimise
    # @param size [Integer, nil] population size override
    # @param mutator [#call, nil] mutator override
    # @param selector [#call, nil] selector override
    # @param combiner [#call, nil] combiner override
    # @param elitism [Integer] top genes carried over unchanged (default 1)
    def initialize(template, fitness_evaluator = nil,
                   seed: nil, direction: :maximise, size: nil,
                   mutator: nil, selector: nil, combiner: nil, elitism: 1,
                   &fitness_block)
      evaluator = resolve_evaluator(fitness_evaluator, fitness_block)

      @bare_template = template.is_a?(Hash)
      internal_template = @bare_template ? [template] : template
      @fitness_adapter = FitnessAdapter.new(evaluator, direction:,
                                                       bare_template: @bare_template)
      random = seed.nil? ? Random.new : Random.new(seed)
      @gene_pool = GenePool.build(internal_template, @fitness_adapter,
                                  random:, size:, mutator:, selector:,
                                  combiner:, elitism:)
    end

    # Optimise the genes and report whether the best fitness improved.
    # @param number_of_generations [Integer] evolve exactly this many
    #   generations. With the default of 0, evolve according to the given
    #   termination options (see #run), or until the best fitness stagnates.
    # @return [Boolean] whether the best fitness improved
    def optimise(number_of_generations = 0, **termination_options)
      if number_of_generations.positive?
        termination_options = termination_options.merge(max_generations: number_of_generations)
      end
      run(**termination_options).improved?
    end
    alias optimize optimise

    # Optimise the genes and return a Result with the best parameters,
    # fitness, per-generation history and run statistics.
    # Termination options compose - the run stops when any is met:
    # @param max_generations [Integer, nil] stop after this many generations
    # @param target_fitness [Numeric, nil] stop when the best fitness
    #   reaches this value (in your fitness space, minding direction)
    # @param patience [Integer, nil] stop after this many generations
    #   without improvement
    # @param max_time [Numeric, nil] stop after this many seconds
    # @param termination [#call, nil] a custom criterion called with the
    #   gene pool (see GeneGenie::Termination)
    # @return [Result]
    def run(max_generations: nil, target_fitness: nil, patience: nil,
            max_time: nil, termination: nil)
      criterion = build_termination(max_generations:, target_fitness:,
                                    patience:, max_time:, termination:)
      criterion.reset if criterion.respond_to?(:reset)

      measure_run { @gene_pool.evolve until criterion.call(@gene_pool) }
    end

    def register_listener(listener)
      @gene_pool.register_listener(listener)
    end

    # The best parameters found so far, in the same shape as the supplied
    # template (a Hash for a Hash template, an Array of Hashes otherwise).
    def best
      hashes = @gene_pool.best_ever.to_hashes
      @bare_template ? hashes.first : hashes
    end

    def best_fitness
      @fitness_adapter.to_user(@gene_pool.best_ever.fitness)
    end

    private

    def resolve_evaluator(fitness_evaluator, fitness_block)
      if fitness_evaluator && fitness_block
        raise ArgumentError, 'supply a fitness evaluator or a block, not both'
      end

      evaluator = fitness_evaluator || fitness_block
      raise ArgumentError, 'supply a fitness evaluator or a block' if evaluator.nil?

      evaluator
    end

    def build_termination(max_generations:, target_fitness:, patience:, max_time:, termination:)
      criteria = explicit_criteria(max_generations:, target_fitness:, patience:,
                                   max_time:, termination:)
      criteria = default_criteria if criteria.empty?
      criteria.one? ? criteria.first : Termination::Any.new(*criteria)
    end

    def explicit_criteria(max_generations:, target_fitness:, patience:, max_time:, termination:)
      criteria = []
      criteria << termination if termination
      criteria << Termination::MaxGenerations.new(max_generations) if max_generations
      if target_fitness
        criteria << Termination::TargetFitness.new(@fitness_adapter.to_internal(target_fitness))
      end
      criteria << Termination::Stagnation.new(patience) if patience
      criteria << Termination::MaxTime.new(max_time) if max_time
      criteria
    end

    def default_criteria
      [Termination::Stagnation.new(STAGNATION_PATIENCE),
       Termination::MaxGenerations.new(DEFAULT_MAX_GENERATIONS)]
    end

    def measure_run
      start_generation = @gene_pool.generation
      start_evaluations = @fitness_adapter.evaluations
      start_best = @gene_pool.best_ever.fitness
      started_at = monotonic_time
      history = []
      history_listener = ->(pool) { history << stat_for(pool) }
      register_listener(history_listener)

      yield

      Result.new(best:, best_fitness:,
                 generations: @gene_pool.generation - start_generation,
                 evaluations: @fitness_adapter.evaluations - start_evaluations,
                 elapsed: monotonic_time - started_at,
                 improved: @gene_pool.best_ever.fitness > start_best,
                 history:)
    ensure
      @gene_pool.unregister_listener(history_listener)
    end

    def stat_for(pool)
      Result::Stat.new(pool.generation,
                       @fitness_adapter.to_user(pool.best_ever.fitness),
                       @fitness_adapter.to_user(pool.average_fitness))
    end

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
