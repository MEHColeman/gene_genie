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
Basic usage is designed to be as simple as possible. You provide two things: an exemplar and an evaluator.
An exemplar is a list of variables along with their possible range of values.
An evaluator implements a fitness method that returns a numeric value.
The genetic algorithm will then search for the set of values that maximises the fitness.

```ruby
require 'gene_genie'

exemplar = {
  range_of_ints: 1..10,
  range_of_floats: 1.0..4.5,
  set_of_items: [:apple, :banana, :orange],
  ordered_set_of_items: [:one, :two, :three],
  circular_ordered_set: [:early_morning, :morning, :noon, :afternoon,
                         :evening, :midnight]
  }
```

If you use the simple genie interface, the genetic algorithm will come up with a reasonable best-guesses for various algorthm parameters, but you can dive under the covers to give yourself more flexibility.
* Population size
* Gene pools
* Initialisation
* Optimisation Criteria

Custom objects for crossover, gene selection, etc.

## Contributing

1. Fork it ( https://github.com/MEHColeman/gene_genie/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
