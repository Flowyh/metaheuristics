# Roulette wheel selection using stochastic acceptance (http://www.sciencedirect.com/science/article/pii/S0378437111009010)
function stochastic_rws(weights::Vector{Float64}, args...)
  min = minimum(weights)
  len = length(weights)
  while true
    i = rand(1:len)
    if (rand() < min / weights[i])
      return i
    end
  end
end

function tournament(weights::Vector{Float64}, lambda::Float64)
  n::Int = round(Int, lambda * length(weights))
  return argmin(sample(weights, n))
end