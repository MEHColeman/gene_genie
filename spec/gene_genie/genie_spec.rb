require 'minitest_helper'
require 'gene_genie'

# The basic Genie class. For the simplest optimisation, with best-guess
# optimisations, this is all you need.
# See template_spec and fitness_evaluator_spec descriptions of the parameters
module GeneGenie
  describe Genie do
    let(:template) do
      { a: [1..100], b: [1..100] }
    end

    before do
      @fitness_evaluator = Class.new do
        def fitness(params)
          params.each_value.inject(:*)
        end
      end
    end

    describe '#initialize' do

      it 'is initialised with a template and a fitness evaluator' do
        genie = Genie.new(@template, @fitness_evaluator)
        assert_kind_of Genie, genie
      end

    end

    describe '#optimise' do

      it 'optimises' do
        genie = Genie.new(@template, @fitness_evaluator)
        assert true, genie.optimise
        optimised = genie.best
        assert true, optimised.fitness > 90*90
      end

      it 'takes an optional number_of_generations argument' do
        genie = Genie.new(@template, @fitness_evaluator)
        assert true, genie.optimise(1)
        optimised = genie.best
        assert optimised.fitness > 2*2
      end

    end

    describe '#best' do

      it 'returns a Gene' do
        genie = Genie.new(@template, @fitness_evaluator)
        genie.optimise(1)
        assert_kind_of Gene, genie.best
      end

      it 'returns the best Gene' do
        genie = Genie.new(@template, @fitness_evaluator)
        assert true, genie.optimise(1)
        optimised_1 = genie.best
        genie.optimise(20)
        optimised_20 = genie.best
        assert true, optimised_1.fitness < optimised_20.fitness
      end

    end
  end

end
