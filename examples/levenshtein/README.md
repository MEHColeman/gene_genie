# Levenshtein Example

bundle intstall
bundle exec ruby string_levenshtein.rb

This example takes a template that represents a string.
The fitness evaluator scores each gene according to it's levenshtein distance
to the target string.
A listener is registered which prints the current best gene after each
generation.

As it turns out, levenshtein distance is an awful metric for measuring fitness
of a string represented by a combinatorial gene. The levenshtein algorithm will
favour strings cannot easily be transformed to the target string via gene
combination, since genes cannot transpose the position of letters

Check out the simple_string example for a similar problem, solved with a
different fitness evaluator.
