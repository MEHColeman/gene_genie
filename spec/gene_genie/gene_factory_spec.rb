require 'minitest_helper'
require 'gene_genie/gene_factory'

module GeneGenie

  describe GeneFactory do
    let(:template) do
      { a: 1..10, b: 2..20 }
    end
    subject { GeneFactory.new(template) }

    describe 'initialize' do
      it 'takes a template argument' do
        assert_kind_of GeneFactory, GeneFactory.new(template)
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
