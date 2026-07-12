require 'gene_genie/gene_pool'

require 'support/custom_gene_factory'
require 'support/samples'

module GeneGenie
  RSpec.describe GenePool do
    subject { GenePool.build(sample_template, sample_fitness_evaluator) }

    describe '.build' do
      it 'requires at least a template and fitness_evaluator' do
        expect(subject).to be_kind_of GenePool
      end

      it 'returns an argument error unless the template is a hash of ranges' do
        template = :not_a_hash_of_ranges

        expect do
          GenePool.build(template, sample_fitness_evaluator)
        end.to raise_error ArgumentError
      end

      it 'returns an argument error unless the fitness_evaluator responds to #fitness' do
        fitness_evaluator = Object.new

        expect do
          GenePool.build(sample_template, fitness_evaluator)
        end.to raise_error ArgumentError
      end
    end

    describe '.new' do
      it 'uses a GeneFactory to create a population of suitable Genes' do
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return(nil)

        GenePool.new(template: sample_template,
                     fitness_evaluator: sample_fitness_evaluator,
                     gene_factory:)
      end

      it 'takes an optional gene mutator' do
        gene_mutator = Object.new
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return(nil)

        GenePool.new(template: sample_template,
                     fitness_evaluator: sample_fitness_evaluator,
                     gene_factory:,
                     size: 10,
                     mutator: gene_mutator)
      end

      it 'takes an optional gene selector' do
        gene_mutator = Object.new
        gene_selector = Object.new
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return(nil)

        GenePool.new(template: sample_template,
                     fitness_evaluator: sample_fitness_evaluator,
                     gene_factory:,
                     size: 10,
                     mutator: gene_mutator,
                     selector: gene_selector)
      end
    end

    describe '#register_listener' do
      it 'adds the listener to the list that gets notified' do
        expect(subject.instance_variable_get(:@listeners).size).to eq 0
        subject.register_listener(Object.new)
        expect(subject.instance_variable_get(:@listeners).size).to eq 1
      end
    end

    describe '#best' do
      it 'returns the gene with the highest fitness' do
        a = b = Gene.new(information: [{ a: 1, b: 1 }],
                         fitness_evaluator: sample_fitness_evaluator)
        c = Gene.new(information: [{ a: 10, b: 10 }],
                     fitness_evaluator: sample_fitness_evaluator)
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return([a, b, c])

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory:)

        expect(gene_pool.best).to eq c
      end
    end

    describe '#worst' do
      it 'returns the gene with the lowest fitness' do
        a = Gene.new(information: [{ a: 1, b: 1 }],
                     fitness_evaluator: sample_fitness_evaluator)
        b = c = Gene.new(information: [{ a: 10, b: 10 }],
                         fitness_evaluator: sample_fitness_evaluator)
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return([a, b, c])

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory:)

        expect(gene_pool.worst).to eq a
      end
    end

    describe '#total_fitness' do
      it 'returns the sum of all fitnesses in the pool' do
        a = Gene.new(information: [{ a: 1, b: 1 }],
                     fitness_evaluator: sample_fitness_evaluator)
        b = c = Gene.new(information: [{ a: 10, b: 10 }],
                         fitness_evaluator: sample_fitness_evaluator)
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return([a, b, c])

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory:)

        expect(gene_pool.total_fitness).to eq 201
      end
    end

    describe '#total_normalised_fitness' do
      it 'returns the sum of all fitnesses in the pool' do
        a = Gene.new(information: [{ a: 1, b: 10 }],
                     fitness_evaluator: sample_fitness_evaluator)
        b = c = Gene.new(information: [{ a: 10, b: 10 }],
                         fitness_evaluator: sample_fitness_evaluator)
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return([a, b, c])

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory:)

        expect(gene_pool.total_normalised_fitness).to eq 180
      end
    end

    describe '#genes' do
      it 'returns the array of genes' do
        expect(subject.genes).to be_kind_of(Array)
        expect(subject.genes[0]).to be_kind_of(Gene)
      end
    end

    describe '#evolve' do
      it 'returns a boolean indicating whether the best gene has improved' do
        old_best_fitness = subject.best.fitness
        result = subject.evolve
        if subject.best.fitness > old_best_fitness
          expect(result).to be_truthy
        else
          expect(result).to be_falsey
        end
      end

      it 'carries the best gene into the next generation unchanged (elitism)' do
        best_before = subject.best

        subject.evolve

        expect(subject.genes).to include best_before
      end

      it 'never lets the best fitness in the pool regress' do
        best_fitness_before = subject.best_fitness

        subject.evolve

        expect(subject.best_fitness).to be >= best_fitness_before
      end

      it 'notifies all the registered listeners' do
        listener = double(:listener)
        expect(listener).to receive(:call).with(subject).and_return(nil)

        subject.register_listener(listener)
        subject.evolve
      end
    end

    describe '#best_ever' do
      it 'remembers the best gene from the initial population, even if evolution regresses' do
        champion = Gene.new(information: [{ a: 100, b: 100 }],
                            fitness_evaluator: sample_fitness_evaluator)
        losers = Array.new(2) do
          Gene.new(information: [{ a: 1, b: 2 }],
                   fitness_evaluator: sample_fitness_evaluator)
        end
        degrading_mutator = lambda do |information|
          information.each do |hash|
            hash[:a] = 1
            hash[:b] = 2
          end
        end

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory: CustomGeneFactory.new([champion] + losers),
                                 mutator: degrading_mutator,
                                 elitism: 0)
        gene_pool.evolve

        expect(gene_pool.best_ever.fitness).to eq 10_000
      end
    end

    describe '#generation' do
      it 'returns the current generation of the gene pool' do
        expect(subject.generation).to eq 0

        subject.evolve

        expect(subject.generation).to eq 1
      end
    end

    describe '#best_fitness' do
      it 'returns the fitness of the best gene' do
        a = b = Gene.new(information: [{ a: 1, b: 1 }],
                         fitness_evaluator: sample_fitness_evaluator)
        c = Gene.new(information: [{ a: 10, b: 10 }],
                     fitness_evaluator: sample_fitness_evaluator)
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return([a, b, c])

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory:)

        expect(gene_pool.best_fitness).to eq 100
      end
    end

    describe '#worst_fitness' do
      it 'returns the fitness of the worst gene' do
        a = Gene.new(information: [{ a: 1, b: 1 }],
                     fitness_evaluator: sample_fitness_evaluator)
        b = c = Gene.new(information: [{ a: 10, b: 10 }],
                         fitness_evaluator: sample_fitness_evaluator)
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return([a, b, c])

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory:)

        expect(gene_pool.worst_fitness).to eq 1
      end
    end

    describe '#average_fitness' do
      it 'returns the average fitness of all genes' do
        a = b = Gene.new(information: [{ a: 1, b: 1 }],
                         fitness_evaluator: sample_fitness_evaluator)
        c = Gene.new(information: [{ a: 10, b: 10 }],
                     fitness_evaluator: sample_fitness_evaluator)
        gene_factory = double :gene_factory

        expect(gene_factory).to receive(:create).with(10).and_return([a, b, c])

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory:)

        expect(gene_pool.average_fitness).to eq 34
      end
    end
  end
end
