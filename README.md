[![Gem Version](https://badge.fury.io/rb/gene_genie.svg)](http://badge.fury.io/rb/gene_genie)
[![CI](https://github.com/MEHColeman/gene_genie/actions/workflows/ci.yml/badge.svg)](https://github.com/MEHColeman/gene_genie/actions/workflows/ci.yml)

# Gene Genie

Hey, I wrote a genetic algorithm gem. Goals:
* Have fun
* Be easy and intuitive to use
* Be open to extension and experimentation

## Installation

Add this line to your application's Gemfile:

    gem 'gene_genie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gene_genie

## Usage

Basic usage is designed to be as simple as possible. You provide two things:
a template and a fitness function.

A template is a hash describing the variables you want to optimise and their
possible values. Values can be integer ranges, float ranges, or arrays of
choices:

~~~ruby
template = {
  whole_number: 1..10,
  continuous: -5.0..5.0,
  pick_one: [:red, :green, :blue]
}
~~~

The fitness function takes a hash of candidate values (matching the shape of
your template) and returns a number. The genetic algorithm searches for the
values that maximise it:

~~~ruby
require 'gene_genie'

genie = GeneGenie::Genie.new(a: 1..100, b: 2..100) do |params|
  params[:a] * params[:b]
end
genie.optimise

puts genie.best.inspect       # => { a: 100, b: 100 }
puts genie.best_fitness       # => 10000
~~~

Typically, your fitness function will build a model from the candidate
values, evaluate the performance of that model, and return a score. It can be
as complicated or simple as you need. Instead of a block, you can pass any
object that responds to `fitness` (or any lambda/proc):

~~~ruby
class Summer
  def fitness(params)
    params.each_value.sum
  end
end

genie = GeneGenie::Genie.new(template, Summer.new)
~~~

### Minimising

To minimise instead of maximise, say so:

~~~ruby
genie = GeneGenie::Genie.new({ x: -10.0..10.0 }, direction: :minimise) do |params|
  (params[:x] - 2.37)**2
end
~~~

### Reproducible runs

Genetic algorithms are stochastic. If you need a reproducible run - for
tests, benchmarks or debugging - pass a seed:

~~~ruby
genie = GeneGenie::Genie.new(template, Summer.new, seed: 42)
~~~

### Results, statistics and stopping conditions

`optimise` returns true/false (did the best fitness improve). For more
detail, use `run`, which returns a `Result` and accepts composable stopping
conditions - the run stops as soon as any is met:

~~~ruby
result = genie.run(target_fitness: 10_000, # stop when this fitness is reached
                   patience: 25,           # or after 25 generations without improvement
                   max_generations: 500,   # or after 500 generations
                   max_time: 10)           # or after 10 seconds

result.best         # the best parameters found
result.best_fitness
result.generations  # how many generations this run evolved
result.evaluations  # how many times your fitness function was called
result.elapsed      # seconds
result.history      # per-generation best/average fitness, for plotting
~~~

You can also pass any object responding to `call(gene_pool)` as
`termination:`, or compose the built-in criteria from
`GeneGenie::Termination` with `|`.

With no options, `run`/`optimise` stop once the best fitness hasn't improved
for 15 generations (or after 100 generations, whichever comes first).

### Monitoring progress

To monitor the optimisation as it happens, register a listener. Listeners
are called after every generation with the underlying `GenePool`:

~~~ruby
genie.register_listener(proc do |pool|
  puts "Generation #{pool.generation}: best #{pool.best_fitness}"
end)
~~~

See the examples directory for more: a float function minimisation, the
knapsack problem, and string evolution.

## Advanced Use

`Genie` builds sensible defaults for every part of the algorithm, and lets
you override any of them:

~~~ruby
genie = GeneGenie::Genie.new(
  template, evaluator,
  seed: 42,
  size: 100,                                                # population size
  elitism: 2,                                               # genes carried over unchanged
  selector: GeneGenie::Selector::TournamentSelector.new,    # parent selection
  combiner: GeneGenie::Combiner::UniformCombiner.new,       # crossover
  mutator: GeneGenie::Mutator::SimpleGeneMutator.new(template, 0.02)
)
~~~

For complete control you can skip `Genie` and use `GenePool` directly -
`GenePool.build` accepts the same component overrides, or `GenePool.new`
takes everything explicitly, including a `gene_factory` controlling how the
initial population is created. Note that `GenePool` works in "always
maximise" terms and expects an object with a `fitness` method (wrap yours in
`GeneGenie::FitnessAdapter` for blocks/minimisation/bare-hash handling).

The components:

* **Selectors** pick parent genes.
  `Selector::ProportionalSelector` (default) is classic roulette-wheel
  selection; `Selector::TournamentSelector` is robust on fitness plateaus
  and insensitive to fitness scale; `Selector::CoinFlipSelector` is a simple
  rank-based alternative.
* **Combiners** control crossover. `Combiner::OnePointCombiner` (default)
  splits the parents at a random point; `Combiner::UniformCombiner` picks
  each value from either parent at random;
  `Combiner::WeightedAverageCombiner` averages the parents' numeric values,
  which suits smooth problems but can never explore outside their range.
* **Mutators** alter genes slightly, mimicking natural mutation.
  `Mutator::NudgeMutator` (default) moves values a small distance;
  `Mutator::SimpleGeneMutator` can move them anywhere in their range;
  `Mutator::NullMutator` does nothing.

All stochastic components take a `random:` keyword - pass the same seeded
`Random` instance to all of them for a reproducible run (or just use
`Genie`'s `seed:`).

`elitism` is the number of top genes carried into each new generation
unchanged (default 1), guaranteeing the pool's best fitness never regresses.

## Contributing

1. Fork it ( https://github.com/MEHColeman/gene_genie/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

~~~
bundle install
bundle exec rspec    # tests
bundle exec rubocop  # lint
~~~
