require 'minitest_helper'
require 'gene_genie/gene_pool'

module GeneGenie
  describe GenePool do
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
        GenePool.new(sample_template,
                     sample_fitness_evaluator,
                     gene_factory)
        gene_factory.verify
      end
    end

    describe '#best' do
      it 'returns the gene with the highest fitness' do
        a = b = Gene.new({ a: 1, b: 1 }, sample_fitness_evaluator)
        c = Gene.new({ a: 10, b: 10 }, sample_fitness_evaluator)

        gene_factory = MiniTest::Mock.new
        gene_factory.expect :create, [a, b, c], [10]

        gene_pool = GenePool.new(sample_template,
                                 sample_fitness_evaluator,
                                 gene_factory)
        assert_equal c, gene_pool.best
      end
    end
  end
end
