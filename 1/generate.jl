using Random
using TSPLIB

function generateCoords(n::Int, coords_range::Int)
  result = []
  rng = MersenneTwister()
  for i in 1:n
    push!(result, (rand(rng, Int) % coords_range, rand(rng, Int) % coords_range))
  end
  return result
end

function euclideanWeights(coords, args...)
  n = size(coords, 1)
  distances = zeros(Real, n, n)
  for i in 1:n, j in 1:n
    if i <= j
      dist_x = (coords[i][1] - coords[j][1]) ^ 2
      dist_y = (coords[i][2] - coords[j][2]) ^ 2
      distances[i, j] = round(sqrt(dist_x + dist_y), RoundNearestTiesUp) 
      distances[j, i] = distances[i, j]
    end
  end
  return distances
end

function asymmetricWeights(coords, coords_range::Int)
  n = size(coords, 1)
  rng = MersenneTwister()
  distances = zeros(Real, n, n)
  for i in 1:n, j in 1:n
    if (i != j)
      distances[i, j] = (rand(rng, UInt) % coords_range) + 1
      distances[j, i] = (rand(rng, UInt) % coords_range) + 1
    end
  end
  return distances
end

function generateProblem(n::Int, generator::Function, coords_range::Int)
  nodes = generateCoords(n, coords_range)
  return (nodes, generator(nodes, coords_range))
end