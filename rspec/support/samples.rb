def sample_template
  [{ a: 1..100, b: 2..100 }]
end

def sample_fitness_evaluator
  fitness_evaluator = Object.new
  def fitness_evaluator.fitness(params)
    params.map { |hash| hash.each_value.reduce(:*) }.reduce(:*) || 1
  end

  fitness_evaluator
end
