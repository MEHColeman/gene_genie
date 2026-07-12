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
Basic usage is designed to be as simple as possible. You provide two things: a
template and an evaluator.

A template is an array of hashes, representing a list of variables along with
their possible range of values that you wish to optimise.

An evaluator implements a fitness method that returns a numeric value.

The genetic algorithm will then search for the set of values that maximises the
fitness.

~~~ruby
require 'gene_genie'

template = [{
  range_of_ints: 1..10,
  more_ints: 3..100
}]
~~~

Typically, your fitness function will create a model represented by the values
specified in the template, evaluate the performance of that model, and return a
fitness score. But, it can be as complicated or simple as you need.

A fitness function should return a float or integer
~~~ruby
class Summer
  def fitness(params)
    params.inject(0) {|acc, values| acc + values.each_value.inject(&:+)}
  end
end
~~~
Then, simply create a Genie, and optimise:
~~~ruby
genie = GeneGenie::Genie.new(template, Summer.new)
genie.optimise

puts genie.best.inspect
~~~
If you want to monitor progress of the optimisation algorithm, you can register
a listener. Listeners are called after every generation with the underlying
`GenePool`:
~~~ruby
genie.register_listener(Proc.new do |pool|
  puts "Best: #{pool.best.to_hashes}, Score: #{pool.best_fitness}"
end)
~~~

Genetic algorithms are stochastic. If you need a reproducible run - for tests,
benchmarks or debugging - pass a seed:
~~~ruby
genie = GeneGenie::Genie.new(template, Summer.new, seed: 42)
~~~

See the examples directory for more details.

If you use the simple `genie` interface, the genetic algorithm will come up with
reasonable best-guesses for various algorithm parameters, but you can dive under
the covers to give yourself more flexibility.

## Advanced Use

If you want more control over your algorithm, you can skip the `Genie`, and use
`GenePool` directly.

This allows you to create objects that are used to control the methods used for
mutation, crossover, gene selection, and gene pool parameters like population
size and elitism.
~~~ruby
require 'gene_genie'

random = Random.new(42) # or Random.new for a non-reproducible run

mutator = GeneGenie::NudgeMutator.new(template, 0.04, random: random)
combiner = GeneGenie::Combiner::UniformCombiner.new(random: random)
gene_factory = GeneGenie::GeneFactory.new(template, fitness_evaluator,
                                          combiner, random: random)
selector = GeneGenie::ProportionalSelector.new(random: random)

size = GeneGenie::TemplateEvaluator.new(template).recommended_size

pool = GeneGenie::GenePool.new(template: template,
                               fitness_evaluator: fitness_evaluator,
                               gene_factory: gene_factory,
                               size: size,
                               mutator: mutator,
                               selector: selector,
                               elitism: 1)
pool.evolve until pool.generation >= 100
puts pool.best_ever.to_hashes.inspect
~~~
The `mutator` operates on a `Gene` to alter it slightly, mimicking natural gene
mutations. `NudgeMutator` moves values a small distance; `SimpleGeneMutator`
can move them anywhere in their range; `NullMutator` does nothing.

The `combiner` controls crossover. `OnePointCombiner` (the default) splits the
parents at a random point; `UniformCombiner` picks each value from either
parent at random; `WeightedAverageCombiner` averages the parents' values, which
suits smooth numeric problems but can never explore outside their range.

The `selector` picks parent genes. `ProportionalSelector` (the default) is
classic roulette-wheel selection; `CoinFlipSelector` is a simple rank-based
alternative.

The `gene_factory` creates the initial population of genes. Genes are
typically generated randomly across the parameter space, but this allows you to
have more control over how genes are distributed across this space.

`elitism` is the number of top genes carried into each new generation
unchanged (default 1), guaranteeing the pool's best fitness never regresses.

All of the stochastic components take a `random:` keyword argument - pass the
same seeded `Random` instance to all of them for a reproducible run.

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
