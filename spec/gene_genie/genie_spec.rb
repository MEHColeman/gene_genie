require 'gene_genie'
require 'gene_genie/template_evaluator'

require 'support/samples'
require 'support/fitness_evaluator_helper'

# The basic Genie class. For the simplest optimisation, with best-guess
# optimisations, this is all you need.
# See template_spec and fitness_evaluator_spec descriptions of the parameters
module GeneGenie
  RSpec.describe Genie do
    let(:genie) { Genie.new(sample_template, sample_fitness_evaluator, seed: 42) }

    describe '#initialize' do
      it 'is initialised with a template and a fitness evaluator' do
        expect(genie).to be_kind_of Genie
      end

      it 'takes an optional seed for reproducible runs' do
        genie_a = Genie.new(sample_template, sample_fitness_evaluator, seed: 123)
        genie_b = Genie.new(sample_template, sample_fitness_evaluator, seed: 123)
        genie_a.optimise(20)
        genie_b.optimise(20)

        expect(genie_a.best).to eq genie_b.best
        expect(genie_a.best_fitness).to eq genie_b.best_fitness
      end
    end

    describe '#optimise' do
      it 'returns true when it improves current best_fitness' do
        changing_fitness_evaluator = TailoredFitnessEvaluator.new(1)

        genie = Genie.new(sample_template, changing_fitness_evaluator)
        genie.best_fitness
        changing_fitness_evaluator.fitness = 2

        expect(genie.optimise(1)).to eq true
      end

      it "returns false when it doesn't improve current best_fitness" do
        unchanging_fitness_evaluator = TailoredFitnessEvaluator.new(1)

        genie = Genie.new(sample_template, unchanging_fitness_evaluator)

        expect(genie.optimise(1)).to eq false
      end

      it 'takes an optional number_of_generations argument' do
        genie.optimise(10)

        expect(genie.gene_pool.generation).to eq 10
      end

      it 'stops early once the best fitness stagnates' do
        unchanging_fitness_evaluator = TailoredFitnessEvaluator.new(1)
        genie = Genie.new(sample_template, unchanging_fitness_evaluator)

        genie.optimise

        expect(genie.gene_pool.generation).to eq Genie::STAGNATION_PATIENCE
      end

      it 'optimises' do
        expect(genie.optimise(200)).to eq true
        expect(genie.best_fitness).to be > (90 * 90), "didn't find a good result"
      end

      it 'also optimizes' do
        expect(genie).to respond_to(:optimize), 'optimize variant not recognised'
      end
    end

    describe '#register_listener' do
      it 'adds the listener to the gene pool' do
        listener = double :listener
        expect(listener).to receive(:call).with(genie.gene_pool).once

        genie.register_listener(listener)
        genie.optimise(1)
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
