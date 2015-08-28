def sample_template
  { a: 1..100, b: 2..100 }
end

def sample_fitness_evaluator
  fitness_evaluator = Object.new
  def fitness_evaluator.fitness(params)
    params.each_value.inject(:*) || 1
  end

  fitness_evaluator
end
