# frozen_string_literal: true

module GeneGenie
  # Termination criteria decide when an optimisation run should stop.
  # A criterion is anything that responds to +call(gene_pool)+ with a
  # boolean - a lambda works fine. The classes here cover the common cases
  # and can be composed with +|+:
  #
  #   Termination::TargetFitness.new(100) | Termination::MaxTime.new(60)
  #
  # Criteria are checked before each generation is evolved; stateful
  # criteria (MaxGenerations, Stagnation, MaxTime) are reset at the start
  # of each run.
  # @since 0.4.0
  module Termination
    # Base class providing composition. Subclasses implement +call(pool)+
    # and, if stateful, +reset+.
    class Base
      def call(_pool)
        raise NotImplementedError
      end

      def reset; end

      def |(other)
        Any.new(self, other)
      end
    end

    # Stops when any of the composed criteria says stop.
    class Any < Base
      def initialize(*criteria)
        super()
        @criteria = criteria
      end

      def call(pool)
        @criteria.any? { |criterion| criterion.call(pool) }
      end

      def reset
        @criteria.each { |criterion| criterion.reset if criterion.respond_to?(:reset) }
      end
    end

    # Stops after the given number of generations, counted from the start
    # of the run.
    class MaxGenerations < Base
      def initialize(limit)
        super()
        @limit = limit
        reset
      end

      def call(pool)
        @start_generation ||= pool.generation
        pool.generation - @start_generation >= @limit
      end

      def reset
        @start_generation = nil
      end
    end

    # Stops once the pool's best-ever fitness reaches the target.
    # The target is in the pool's own (always-maximising) fitness space;
    # Genie translates minimisation targets before building this.
    class TargetFitness < Base
      def initialize(target)
        super()
        @target = target
      end

      def call(pool)
        pool.best_ever.fitness >= @target
      end
    end

    # Stops once the best-ever fitness has not improved for +patience+
    # consecutive generations.
    class Stagnation < Base
      def initialize(patience = 15)
        super()
        @patience = patience
        reset
      end

      def call(pool)
        fitness = pool.best_ever.fitness
        if @best_seen.nil? || fitness > @best_seen
          @best_seen = fitness
          @stagnant_generations = 0
        else
          @stagnant_generations += 1
        end
        @stagnant_generations >= @patience
      end

      def reset
        @best_seen = nil
        @stagnant_generations = 0
      end
    end

    # Stops once the run has taken longer than the given number of seconds.
    class MaxTime < Base
      def initialize(seconds, clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) })
        super()
        @seconds = seconds
        @clock = clock
        reset
      end

      def call(_pool)
        @started_at ||= @clock.call
        @clock.call - @started_at >= @seconds
      end

      def reset
        @started_at = nil
      end
    end
  end
end
