using Random
using TSPLIB

"""
Generates Coordinates.

## Params:
- `n::Int`: Number of coordinates to generate.
- `coords_range::Int`: Maximum number for coordinate that can be generated (excluding).

## returns:
- `result::Array{Tuple{Int, Int}}` Array of generated coordinates.

"""
function generateCoords(n::Int, coords_range::Int)
  result = []
  rng = MersenneTwister()
  for i in 1:n
    push!(result, (rand(rng, Int) % coords_range, rand(rng, Int) % coords_range))
  end
  return result
end

"""
Calculates weights for euclidean type data.

## Params:
- `coords`: Coordinates we use to calculate weights.

## returns:
- `distances::Array{Integer}` Array of calculated distances.

"""
function euclideanWeights(coords, args...)
  n = size(coords, 1)
  distances = zeros(Float64, n, n)
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

"""
Calculates weights for asymmetric type data.

## Params:
- `coords`: Coordinates we use to calculate weights.
- `coords_range::Int`: Maximum number for distance that can be generated (including).

## returns:
- `distances::Array{Integer}` Array of calculated distances.

"""
function asymmetricWeights(coords, coords_range::Int)
  n = size(coords, 1)
  rng = MersenneTwister()
  distances = zeros(Float64, n, n)
  for i in 1:n, j in 1:n
    if (i != j)
      distances[i, j] = (rand(rng, UInt) % coords_range) + 1
      distances[j, i] = (rand(rng, UInt) % coords_range) + 1
    end
  end
  return distances
end

"""
Generates TSP problem from given generator``.

## Params:
- `n::Int`: Number of nodes to generate.
- `generator::Function`: Function to generate specific type data (euclidean or asymmetric).
- `coords_range::Int`: Maximum number for distance that can be generated in generator function.

## returns:
- `Array` Array of generated nodes and their weights.

"""
function generateProblem(n::Int, generator::Function, coords_range::Int)
  nodes = generateCoords(n, coords_range)
  return (nodes, generator(nodes, coords_range))
end

"""
Generate Euclidean TSP problem.

## Params:
- `n::Int`: Number of nodes to generate.

## returns:
- `Array` Array of nodes and their weights.

"""
function generateEuclidean(n::Int, coords_range::Int)
  return generateProblem(n, euclideanWeights, coords_range)
end

"""
Generate Asymmetric TSP problem.

## Params:
- `n::Int`: Number of nodes to generate.
- `coords_range::Int`: Maximum number for distance that can be generated (including).

## returns:
- `Array` Array of nodes and their weights.

"""
function generateAsymmetric(n::Int, coords_range::Int)
  return generateProblem(n, asymmetricWeights, coords_range)
end