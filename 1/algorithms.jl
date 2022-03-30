using Random

"""
    nodeWeightSum(path, weights) -> Float64

Returns path's weight.

## Params:
- `path::Vector{T<:Integer}`: visited nodes in a given path.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.

## Returns:
- `Float64`: Sum of weights between nodes in given path.

"""
function nodeWeightSum(path::Vector{T}, weights::AbstractMatrix{Float64}) where T<:Integer
  @assert isperm(path) "Invalid path provided"
  result = length(path) != size(weights, 1) ? zero(Float64) : weights[path[end], path[1]]
  for i = 1:length(path)-1
    result += weights[path[i], path[i + 1]]
  end
  return result
end


"""
    krandom(tsp_data) -> Array{Integer}

Returns a random permutation of given length.

## Params:
- `tsp_data::Dict`: `TSP` dataset.

## Returns:
- Permutation of `TSP` dataset nodes.

"""
function krandom(tsp_data::Dict, args...)
  if (length(args) < 1) return end
  best_path = shuffle(collect(1:tsp_data[:dimension]))
  best_dist = nodeWeightSum(best_path, tsp_data[:weights])
  for i in 2:args[1]
    path = shuffle(collect(1:tsp_data[:dimension]))
    dist = nodeWeightSum(path, tsp_data[:weights])
    if (dist < best_dist)
      best_dist = dist
      best_path = path
    end
  end
  return best_path
end

function nearestNeighbour(tsp_data::Dict, args...)
  if (length(args) < 1) return end
  len = tsp_data[:dimension]
  path = Vector{Int}()
  current_point = args[1]
  push!(path, current_point)

  for i in 1:(len-1)
    weights = tsp_data[:weights][path[i], :]
    current_weight = typemax(Float64)
    index = 1
    for weight in weights
      if (!(index in path) && current_weight > weight && weight != 0)
        current_weight = weight
        current_point = index
      end
      index += 1
    end
    index = 1
    push!(path, current_point)
  end
  return path
end

function repetitiveNearestNeighbour(tsp_data::Dict, args...)
  path = nearestNeighbour(tsp_data, 1)
  goal = nodeWeightSum(path, tsp_data[:weights])
  for i in 2:tsp_data[:dimension]
    tmp_path = nearestNeighbour(tsp_data, i)
    tmp_goal = nodeWeightSum(tmp_path, tsp_data[:weights])
    if (tmp_goal < goal)
      goal = tmp_goal
      path = tmp_path
    end
  end
  return path
end

"""
    twoopt(tsp_data) -> Array{Integer}

Calculate best path of n nodes and their weights using 2-OPT algorithm.

Initial path is chosen at random using krandom().

## Params:
- `tsp_data::Dict`: `TSP` dataset.

## returns:
- `Array{Integer}` Best path computed.

"""
function twoopt(tsp_data::Dict, args...)
  steps = false
  if (length(args) == 1) path = args[1]
  if (length(args) == 2) steps = args[2] end
  else path = krandom(tsp_data) end
  
  function swap(x, y)
    swapped_path = copy(path)
    swapped_path[x:y] = swapped_path[y:-1:x]
    return swapped_path
  end
  best_distance = nodeWeightSum(path, tsp_data[:weights])
  for i in 1:length(path) - 1
    if (steps) println("STEP $i") end 
    for j in i+1:length(path)
      current_neigh = swap(i, j)
      @assert isperm(current_neigh)
      current_distance = nodeWeightSum(current_neigh, tsp_data[:weights])
      if (current_distance < best_distance) 
        best_distance = current_distance
        path = current_neigh
      end
    end
  end
  return path
end