require 'gene_genie'

RSpec.describe GeneGenie do
  it 'loads the entire public API from a single require' do
    expect(defined?(GeneGenie::Genie)).to be_truthy
    expect(defined?(GeneGenie::GenePool)).to be_truthy
    expect(defined?(GeneGenie::Termination::Stagnation)).to be_truthy
    expect(defined?(GeneGenie::Result)).to be_truthy
    expect(defined?(GeneGenie::Combiner::UniformCombiner)).to be_truthy
    expect(defined?(GeneGenie::Mutator::NudgeMutator)).to be_truthy
    expect(defined?(GeneGenie::Selector::TournamentSelector)).to be_truthy
    expect(defined?(GeneGenie::Listener::LoggingListener)).to be_truthy
  end

  it 'keeps deprecated top-level aliases for pre-0.4 namespaces' do
    {
      NullMutator: GeneGenie::Mutator::NullMutator,
      SimpleGeneMutator: GeneGenie::Mutator::SimpleGeneMutator,
      NudgeMutator: GeneGenie::Mutator::NudgeMutator,
      ProportionalSelector: GeneGenie::Selector::ProportionalSelector,
      CoinFlipSelector: GeneGenie::Selector::CoinFlipSelector
    }.each do |old_name, current|
      expect(GeneGenie.const_get(old_name)).to be current
    end
  end
end
