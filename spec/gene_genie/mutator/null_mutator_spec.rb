require 'gene_genie/mutator/null_mutator'

module GeneGenie
  RSpec.describe NullMutator do
    let(:hash_under_test) { { a: 1, b: 2, c: 3, d: 4, } }
    subject { NullMutator.new }

    describe '#call' do
      it 'returns the same hash, mutating nothing' do
        original_hash = Marshal.load(Marshal.dump(hash_under_test))
        expect(hash_under_test).to eq original_hash
        expect(subject.call(hash_under_test)).to eq original_hash
      end
    end
  end
end
