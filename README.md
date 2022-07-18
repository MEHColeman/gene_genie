[![Build Status](https://travis-ci.org/MEHColeman/gene_genie.svg?branch=master)](https://travis-ci.org/MEHColeman/gene_genie)
[![Gem Version](https://badge.fury.io/rb/gene_genie.svg)](http://badge.fury.io/rb/gene_genie)
[![Code Climate](https://codeclimate.com/github/MEHColeman/gene_genie.png)](https://codeclimate.com/github/MEHColeman/gene_genie)

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

<!---
  range_of_floats: 1.0..4.5,
  set_of_items: [:apple, :banana, :orange],
  ordered_set_of_items: [:one, :two, :three],
  circular_ordered_set: [:early_morning, :morning, :noon, :afternoon,
                         :evening, :midnight]
-->
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
a listener:
~~~ruby
genie.register_listener(Proc.new do |g|
  puts "Best score: '#{g.best.to_hashes.to_s}', Score: #{g.best_fitness}"
end)
~~~
See the examples directory for more details.

If you use the simple `genie` interface, the genetic algorithm will come up with
reasonable best-guesses for various algorithm parameters, but you can dive under
the covers to give yourself more flexibility.
* Population size
* Gene pools
* Initialization
* Optimisation Criteria

Custom objects for crossover, gene selection, etc.

Note:
Due to the non-deterministic nature of the algorithm, some of the tests don't
pass every time at the moment! This is a known issue.

## Contributing

1. Fork it ( https://github.com/MEHColeman/gene_genie/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
