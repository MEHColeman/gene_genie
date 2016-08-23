require 'minitest_helper'
require 'gene_genie/gene_factory'
require 'gene_genie/combiner/uniform_combiner'

module GeneGenie

  describe GeneFactory do
    subject { GeneFactory.new(sample_template, sample_fitness_evaluator) }

    describe 'initialize' do
      it 'takes template and fitness_evaluator arguments' do
        assert_kind_of GeneFactory, subject
      end

      it 'takes template and fitness_evaluator arguments' do
    subject = GeneFactory.new(sample_template,
                              sample_fitness_evaluator,
                              GeneGenie::Combiner::UniformCombiner.new)
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
      it 'can take a template of an array of hashes' do
        template = [{ a: 1..100, b: 2..100 },
                    { c:1..1000, d: 4..8},
                    { e:0..1,    f: 1..9}]
        test_subject = GeneFactory.new(template, sample_fitness_evaluator)
        genes = test_subject.create(30)
        assert_equal 100, test_subject.create(100).size
      end
    end
  end
end
