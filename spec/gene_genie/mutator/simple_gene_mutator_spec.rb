require 'minitest_helper'
require 'gene_genie/mutator/simple_gene_mutator'

module GeneGenie
  describe SimpleGeneMutator do
    let(:template) { [{
      a: 1..1000,
      b: 1..1000,
      c: 1..1000,
      d: 1..1000,
      e: 1..1000,
      f: 1..1000,
      g: 1..1000,
    }] }

    let(:mutation_rate) { 0.5 }

    let(:valid_hash) { [{
      a: 100,
      b: 200,
      c: 300,
      d: 400,
      e: 500,
      f: 600,
      g: 700,
    }] }

    subject { SimpleGeneMutator.new(template, mutation_rate) }

    describe '#initialize' do
      it 'is initialised with a gene template and a mutation rate' do
        gm = SimpleGeneMutator.new(template, mutation_rate)
        assert_kind_of SimpleGeneMutator, gm
      end
    end

    describe '#call' do
      it 'mutates the hash' do
        original_hash = Marshal.load(Marshal.dump(valid_hash))
        assert_equal original_hash, valid_hash
        refute_equal original_hash, subject.call(valid_hash)
      end

      it 'returns a valid hash' do
        # pending
      end
    end
  end
end
