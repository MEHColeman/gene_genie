# Levenshtein Example

~~sh
bundle install
bundle exec ruby string_levenshtein.rb
~~

This example takes a template that represents a string.
The fitness evaluator scores each gene according to it's levenshtein distance
to the target string.
A listener is registered which prints the current best gene after each
generation.

As it turns out, levenshtein distance is an awful metric for measuring fitness
of a string represented by a combinatorial gene. This fitness metric does not usefully
discriminate between good and better strings there are only target_string.length
possible scores for all the combinations of strings in the search-space.

Check out the simple_string and dumb_string examples for a similar problem,
solved with a different fitness evaluator.
