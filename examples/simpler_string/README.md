# Simpler Example

~~~sh
bundle install
bundle exec ruby simpler_string.rb
~~~

This example takes a template that represents a string.
The fitness evaluator scores each gene according to it's hamming distance
to the target string, plus a couple of tweaks.

A listener is registered which prints the current best gene after each
generation.
