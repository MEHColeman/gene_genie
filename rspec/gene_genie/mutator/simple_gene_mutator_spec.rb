require 'gene_genie/mutator/simple_gene_mutator'
require 'gene_genie/template_evaluator'

module GeneGenie
  RSpec.describe SimpleGeneMutator do
    let(:template) { [{
      a: 1..1000,
      b: 1..1000,
      c: 1..1000,
      d: 1..1000,
      e: 1..1000,
      f: 1..1000,
      g: 1..1000
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
        expect(gm).to be_kind_of(SimpleGeneMutator)
      end
    end

    describe '#call' do
      it 'mutates the hash' do
        original_hash = Marshal.load(Marshal.dump(valid_hash))
        expect(valid_hash).to eq original_hash
        expect(subject.call(valid_hash)).not_to eq original_hash
      end

      it 'returns a valid hash' do
        expect(TemplateEvaluator.new(template).hash_valid?(valid_hash)).to be_truthy
      end
    end
  end
end
