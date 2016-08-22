# Levenshtein Example

bundle intstall
bundle exec ruby string_levenshtein.rb

This example takes a template that represents a string.
The fitness evaluator scores each gene according to it's levenshtein distance
to the target string.
A listener is registered which prints the current best gene after each
generation.
