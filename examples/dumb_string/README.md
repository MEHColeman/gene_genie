# Dumb String Example

bundle install
bundle exec ruby dumb_string.rb

![example output](https://raw.githubusercontent.com/MEHColeman/gene_genie/master/examples/dumb_string/dumb_test.gif)

This example takes a template that represents a string.
The fitness evaluator scores each gene according to the sum of the squares of
the disance between the target letter and actual letter.

A listener is registered which prints the current best gene after each
generation.
