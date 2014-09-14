require 'minitest_helper'
require 'gene_genie/gene_factory'

module GeneGenie

  describe GeneFactory do
    subject { GeneFactory.new }
    let(:template) do
      { a: 1..10, b: 2..20 }
    end

    describe '#create' do
      it 'takes a template and a population size' do
      end

      it 'returns an array of 1 gene if size not specified' do
        assert_equal 1, subject.create(template).size
      end

      it 'returns an array of genes of the specified size' do
        assert_equal 4, subject.create(template, 4).size
      end

    end

  end
end
