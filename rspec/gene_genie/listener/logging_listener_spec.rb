require 'gene_genie/listener/logging_listener'
require 'gene_genie/gene_pool'

require 'support/samples'

module GeneGenie
  module Listener
    RSpec.describe LoggingListener do
      let(:logger) { double :logger }
      let(:pool) { GenePool.build(sample_template, sample_fitness_evaluator) }
      subject { LoggingListener.new(logger) }

      describe '.initialize' do
        it 'takes a logger' do
          expect(subject).to be_kind_of LoggingListener
        end
      end

      describe '#call' do
        it 'logs information to the supplied logger' do
          expect(logger).to receive(:info).with(String).exactly(4).times
          subject.call(pool)
        end
      end
    end
  end
end
