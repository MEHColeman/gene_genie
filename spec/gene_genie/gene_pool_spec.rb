require 'minitest_helper'
require 'gene_genie/gene_pool'

module GeneGenie
  describe GenePool do
    subject { GenePool.build(sample_template, sample_fitness_evaluator) }

    describe '.build' do
      it 'requires at least a template and fitness_evaluator' do
        gene_pool = GenePool.build(sample_template, sample_fitness_evaluator)

        assert_kind_of GenePool, gene_pool
      end

      it 'returns an argument error unless the template is a hash of ranges' do
        template = :not_a_hash_of_ranges

        assert_raises(ArgumentError) do
          GenePool.build(template, sample_fitness_evaluator)
        end
      end

      it 'returns an argument error unless the fitness_evaluator responds to #fitness' do
        fitness_evaluator = Object.new

        assert_raises(ArgumentError) do
          GenePool.build(sample_template, fitness_evaluator)
        end
      end
    end

    describe '.new' do
      it 'uses a GeneFactory to create a population of suitable Genes' do
        gene_factory = MiniTest::Mock.new
        gene_factory.expect :create, [], [10]
        GenePool.new(template: sample_template,
                     fitness_evaluator: sample_fitness_evaluator,
                     gene_factory: gene_factory)
        gene_factory.verify
      end

      it 'takes an optional gene mutator' do
        gene_mutator = Object.new
        gene_factory = MiniTest::Mock.new
        gene_factory.expect :create, [], [10]
        GenePool.new(template: sample_template,
                     fitness_evaluator: sample_fitness_evaluator,
                     gene_factory: gene_factory,
                     size: 10,
                     mutator: gene_mutator)
      end

      it 'takes an optional gene selector' do
        gene_mutator = Object.new
        gene_selector = Object.new
        gene_factory = MiniTest::Mock.new
        gene_factory.expect :create, [], [10]
        GenePool.new(template: sample_template,
                     fitness_evaluator: sample_fitness_evaluator,
                     gene_factory: gene_factory,
                     size: 10,
                     mutator: gene_mutator,
                     selector: gene_selector)

      end
    end

    describe '#best' do
      it 'returns the gene with the highest fitness' do
        a = b = Gene.new([{ a: 1, b: 1 }], sample_fitness_evaluator)
        c = Gene.new([{ a: 10, b: 10 }], sample_fitness_evaluator)

        gene_factory = MiniTest::Mock.new
        gene_factory.expect :create, [a, b, c], [10]

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory: gene_factory)

        assert_equal c, gene_pool.best
      end
    end

    describe '#worst' do
      it 'returns the gene with the lowest fitness' do
        a = Gene.new([{ a: 1, b: 1 }], sample_fitness_evaluator)
        b = c = Gene.new([{ a: 10, b: 10 }], sample_fitness_evaluator)

        gene_factory = MiniTest::Mock.new
        gene_factory.expect :create, [a, b, c], [10]

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory: gene_factory)

        assert_equal a, gene_pool.worst
      end
    end

    describe '#evolve' do
      it 'returns a boolean indicating whether the best gene has improved' do
        old_best_fitness = subject.best.fitness
        result = subject.evolve
        if subject.best.fitness > old_best_fitness
          assert result
        else
          refute result
        end
      end

      it 'combines genes based on their score to create a new set of genes' do
        # pending
      end
    end

    describe '#best_fitness' do
      it 'returns the fitness of the best gene' do
        a = b = Gene.new([{ a: 1, b: 1 }], sample_fitness_evaluator)
        c = Gene.new([{ a: 10, b: 10 }], sample_fitness_evaluator)

        gene_factory = MiniTest::Mock.new
        gene_factory.expect :create, [a, b, c], [10]

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory: gene_factory)

        assert_equal 100, gene_pool.best_fitness
      end
    end

    describe '#worst_fitness' do
      it 'returns the fitness of the worst gene' do
        a = Gene.new([{ a: 1, b: 1 }], sample_fitness_evaluator)
        b = c = Gene.new([{ a: 10, b: 10 }], sample_fitness_evaluator)

        gene_factory = MiniTest::Mock.new
        gene_factory.expect :create, [a, b, c], [10]

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory: gene_factory)

        assert_equal 1, gene_pool.worst_fitness
      end
    end

    describe '#average_fitness' do
      it 'returns the average fitness of all genes' do
        a = b = Gene.new([{ a: 1, b: 1 }], sample_fitness_evaluator)
        c = Gene.new([{ a: 10, b: 10 }], sample_fitness_evaluator)

        gene_factory = MiniTest::Mock.new
        gene_factory.expect :create, [a, b, c], [10]

        gene_pool = GenePool.new(template: sample_template,
                                 fitness_evaluator: sample_fitness_evaluator,
                                 gene_factory: gene_factory)

        assert_equal 34, gene_pool.average_fitness
      end
    end
  end
end
