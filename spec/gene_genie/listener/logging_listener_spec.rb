require 'minitest_helper'
require 'gene_genie/listener/logging_listener'
require 'gene_genie/gene_pool'

module GeneGenie
  module Listener

    describe LoggingListener do
      let(:logger) { MiniTest::Mock.new }
      let(:pool) { GenePool.build(sample_template, sample_fitness_evaluator) }
      subject { LoggingListener.new(logger) }

      describe '.initialize' do
        it 'takes a logger' do
          assert_kind_of LoggingListener, subject
        end
      end

      describe '#call' do
        it 'logs information to the supplied logger' do
          4.times do logger.expect :info, nil, [String] end
          subject.call(pool)
          logger.verify
        end
      end
    end
  end
end
