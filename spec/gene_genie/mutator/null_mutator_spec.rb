require 'minitest_helper'
require 'gene_genie/mutator/null_mutator'

module GeneGenie
  describe NullMutator do

    let(:hash_under_test) { { a: 1, b: 2, c: 3, d: 4, } }
    subject { NullMutator.new }

    describe '#call' do
      it 'returns the same hash, mutating nothing' do
        original_hash = Marshal.load(Marshal.dump(hash_under_test))
        assert_equal original_hash, hash_under_test
        assert_equal original_hash, subject.call(hash_under_test)
      end
    end

  end
end
