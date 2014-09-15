require 'minitest_helper'
require 'gene_genie/gene_factory'

module GeneGenie

  describe GeneFactory do
    subject { GeneFactory.new(sample_template, sample_fitness_evaluator) }

    describe 'initialize' do
      it 'takes template and fitness_evaluator arguments' do
        assert_kind_of GeneFactory, subject
      end
    end

    describe '#create' do
      it 'returns an array of 1 gene if size not specified' do
        assert_equal 1, subject.create.size
      end

      it 'returns an array of genes of the specified size' do
        assert_equal 4, subject.create(4).size
      end

    end

  end
end
