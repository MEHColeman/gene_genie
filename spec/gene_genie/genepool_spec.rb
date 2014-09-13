require 'minitest_helper'
require 'gene_pool'

module GeneGenie

  describe GenePool do
    let(:template) do
      { a: 1..10, b: 2..20 }
    end

    before do
      @fitness_evaluator = Object.new
      def @fitness_evaluator.fitness(params)
        params.each_value.inject(:*)
      end
    end

    describe '.build' do
      it 'requires at least a template and fitness_evaluator' do
        gene_pool = GenePool.build(template, @fitness_evaluator)

        assert_kind_of GenePool, gene_pool
      end

      it 'returns an argument error unless the template is a hash of ranges' do
        template = :not_a_hash_of_ranges

        assert_raises(ArgumentError) do
          gene_pool = GenePool.build(template, @fitness_evaluator)
        end
      end

      it 'returns an argument error unless the fitness_evaluator responds to #fitness' do
        fitness_evaluator = Object.new

        assert_raises(ArgumentError) do
          gene_pool = GenePool.build(template, fitness_evaluator)
        end
      end
    end

    describe '.new' do
      it 'also injects a template analyser' do

      end
    end

  end
end
