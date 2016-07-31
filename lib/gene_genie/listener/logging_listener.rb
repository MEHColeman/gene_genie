module GeneGenie
  module Listener
    class LoggingListener
      def initialize(logger)
        @logger = logger
        @last_time = Time.now
      end

      def call(pool)
        @logger.info "Pool Generation ##{pool.generation}"
        @logger.info "Average Fitness: #{pool.average_fitness}"
        @logger.info "Best Fitness:    #{pool.best_fitness}"
        @logger.info "Time elapsed:    #{Time.now - @last_time}"
        @last_time = Time.now
      end
    end
  end
end
