require 'minitest_helper'
require 'gene_genie'

# The basic Genie class. For the simplest optimisation, with best-guess
# optimisations, this is all you need.
# See template_spec and fitness_evaluator_spec descriptions of the parameters
module GeneGenie
  describe Genie do
    let(:template) do
      { a: 1..100, b: 1..100 }
    end

    before do
      @fitness_evaluator = Object.new
      def @fitness_evaluator.fitness(params)
        params.each_value.inject(:*) || 1
      end
    end

    describe '#initialize' do
      it 'is initialised with a template and a fitness evaluator' do
        genie = Genie.new(template, @fitness_evaluator)
        assert_kind_of Genie, genie
      end
    end

    describe '#optimise' do
      before do
        @genie = Genie.new(template, @fitness_evaluator)
      end

      it 'returns true when it successfully optimises' do
        assert_equal true, @genie.optimise
      end

      it 'optimises' do
        assert_equal true, @genie.optimise
        assert_equal true, @genie.best_fitness > (90 * 90)
      end

      it 'also optimizes' do
        assert_equal true, @genie.optimize
      end

      it "returns false if it doesn't improve current best_fitness" do
        template = { a: 1..3, b: 1..3 }
        genie = Genie.new(template, @fitness_evaluator)
        first_fitness = genie.best_fitness
        def @fitness_evaluator.fitness(_)
          20
        end
        assert_equal true, genie.optimise(10)

        second_fitness = genie.best_fitness
        assert second_fitness > first_fitness

        def @fitness_evaluator.fitness(_)
          10
        end
        assert_equal false, genie.optimise(10)

        third_fitness = genie.best_fitness
        assert third_fitness < second_fitness
      end

      it 'takes an optional number_of_generations argument' do
        assert_equal true, @genie.optimise(1)
      end
    end

    describe '#best' do
      before do
        @genie = Genie.new(template, @fitness_evaluator)
      end

      it 'returns a Hash, conforming to the supplied template' do
        @genie.optimise(1)
        optimised = @genie.best
        assert_kind_of Hash, optimised
        template.each do |k, v|
          refute_nil optimised[k]
          assert_equal true, optimised[k] >= v.min
          assert_equal true, optimised[k] <= v.max
        end
      end

      it 'returns optimised data' do
        @genie.optimise(1)
        optimised_1 = @genie.best
        optimised_1_fitness = @fitness_evaluator.fitness(optimised_1)

        @genie.optimise
        optimised_many = @genie.best
        optimised_many_fitness = @fitness_evaluator.fitness(optimised_many)

        assert_equal true, optimised_1_fitness < optimised_many_fitness
        # this test might not always pass. #statistics
      end
    end

    describe '#best_fitness' do
      it 'returns the fitness of the best gene' do
        genie = Genie.new(template, @fitness_evaluator)
        genie.optimise(1)
        optimised = genie.best
        optimised_fitness = @fitness_evaluator.fitness(optimised)
        assert_equal true, optimised_fitness == genie.best_fitness
      end
    end
  end
end
