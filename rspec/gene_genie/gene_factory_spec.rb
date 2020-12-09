require 'gene_genie/gene_factory'
require 'gene_genie/combiner/uniform_combiner'

require 'support/samples'

module GeneGenie
  RSpec.describe GeneFactory do
    subject { GeneFactory.new(sample_template, sample_fitness_evaluator) }

    describe 'initialize' do
      it 'takes template and fitness_evaluator arguments' do
        expect(subject).to be_kind_of GeneFactory
      end

      it 'takes template and fitness_evaluator arguments' do
        subject = GeneFactory.new(sample_template,
                                  sample_fitness_evaluator,
                                  GeneGenie::Combiner::UniformCombiner.new)
        expect(subject).to be_kind_of GeneFactory
      end
    end

    describe '#create' do
      it 'returns an array of 1 gene if size not specified' do
        expect(subject.create.size).to eq 1
      end

      it 'returns an array of genes of the specified size' do
        expect(subject.create(4).size).to eq 4
      end
      it 'can take a template of an array of hashes' do
        template = [{ a: 1..100, b: 2..100 },
                    { c:1..1000, d: 4..8},
                    { e:0..1,    f: 1..9}]
        test_subject = GeneFactory.new(template, sample_fitness_evaluator)
        genes = test_subject.create(30)

        expect(test_subject.create(100).size).to eq 100
      end
    end
  end
end
