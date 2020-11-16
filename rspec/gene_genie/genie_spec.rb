require 'gene_genie'
require 'gene_genie/template_evaluator'

require 'support/samples'
require 'support/fitness_evaluator_helper'

# The basic Genie class. For the simplest optimisation, with best-guess
# optimisations, this is all you need.
# See template_spec and fitness_evaluator_spec descriptions of the parameters
module GeneGenie
  RSpec.describe Genie do

    let(:genie) { Genie.new(sample_template, sample_fitness_evaluator) }
    describe '#initialize' do
      it 'is initialised with a template and a fitness evaluator' do
        expect(genie).to be_kind_of Genie
      end
    end

    describe '#optimise' do
      it 'returns true when it improves current best_fitness' do
        changing_fitness_evaluator = TailoredFitnessEvaluator.new(1)

        genie = Genie.new(sample_template, changing_fitness_evaluator)
        first_fitness = genie.best_fitness
        changing_fitness_evaluator.set_fitness(2)

        expect(genie.optimise(1)).to eq true
      end

      it "returns false when it doesn't improve current best_fitness" do
        unchanging_fitness_evaluator = TailoredFitnessEvaluator.new(1)

        genie = Genie.new(sample_template, unchanging_fitness_evaluator)
        first_fitness = genie.best_fitness

        expect(genie.optimise(1)).to eq false
      end

      it 'takes an optional number_of_generations argument' do
        genie.optimise(10)
        # evolve should be called on genepool 10 times
      end

      it 'optimises' do
        expect(genie.optimise(2000)).to eq true
        expect(genie.best_fitness).to be > (90 * 90), "didn't find a good result"
      end

      it 'also optimizes' do
        expect(genie).to respond_to(:optimize), 'optimize variant not recognised'
      end
    end

    describe '#register_listener' do
      it 'adds the listener to the gene pool' do
      end
    end

    describe '#best' do
      it 'returns an Array of Hashes, conforming to the supplied template' do
        optimised = genie.best
        expect(optimised).to be_kind_of Array
        expect(optimised[0]).to be_kind_of Hash

        expect(TemplateEvaluator.new(sample_template).hash_valid?(optimised)).to eq true
        sample_template.each_with_index do |h, index|
          h.each do |k, v|
            expect(optimised[index][k]).not_to be_nil
            expect(optimised[index][k]).to be >= v.min
            expect(optimised[index][k]).to be <= v.max
          end
        end
      end

      it 'returns optimised data' do
        initial_best = genie.best
        initial_best_fitness = sample_fitness_evaluator.fitness(initial_best)

        genie.optimise

        optimised_many = genie.best
        optimised_many_fitness = sample_fitness_evaluator.fitness(optimised_many)

        expect(initial_best_fitness).to be < optimised_many_fitness, 'fitness did not improve'
        # this test might not always pass. #statistics
      end
    end

    describe '#best_fitness' do
      it 'returns the fitness of the best gene' do
        genie.optimise(1)
        optimised = genie.best
        optimised_fitness = sample_fitness_evaluator.fitness(optimised)
        expect(optimised_fitness).to eq genie.best_fitness
      end
    end
  end
end
