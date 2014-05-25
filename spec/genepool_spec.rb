require 'minitest_helper'
require 'gene_pool'

module GeneGenie

  describe GenePool do
    it 'is initialised with a size and an intepreter' do
      gene_pool = GenePool.new(size: 10, interpreter: nil)
      assert_kind_of GenePool, gene_pool
    end
  end

end
