"""
Inverts path via path[x] and path[y]

## Params:
- `path::Vector{Int}`: Path that we make invert on
- `x::Int`: First position in path
- `y::Int`: Second position in path

## Returns:
- `path::Vector{Int}`: Inverted path

"""
function invert(path::Vector{Int}, x::Int, y::Int)::Vector{Int}
  inverted_path::Vector{Int} = copy(path)
  inverted_path[x:y] = inverted_path[y:-1:x]
  return inverted_path
end

"""
Prepares move, function to calculate new path length, useless function

## Returns:
Tuple contatining:
- `invert:Function`: move invert
- `function`: function to calculate new path length
- `function`: new value 

"""
function moveInvert()::Tuple{Function, Function, Function}
  return (
    invert,
    function(path::Vector{Int}, move::Tuple{Int, Int, Float64}, weights::Matrix{Float64})
      x::Int, y::Int, distance::Float64 = move

      nodes::Int = size(weights, 1)
      if (x == 1 && y == nodes) return distance end # Edge case, everything should stay the same
      prev_x::Int = x - 1 == 0 ? nodes : x - 1
      next_y::Int = y + 1 > nodes ? 1 : y + 1
      
      result::Float64 = distance
      result -= weights[path[prev_x], path[y]]
      result -= weights[path[x], path[next_y]] 
      result += weights[path[prev_x], path[x]]
      result += weights[path[y], path[next_y]]
      
      @assert result == nodeWeightSum(path, weights)
      return result
    end,
    function(i::Int) return i + 1 end
  )
end

"""
Swaps path[x] with path[y]

## Params:
- `path::Vector{Int}`: Path that we make swap on
- `x::Int`: First position in path
- `y::Int`: Second position in path

## Returns:
- `path::Vector{Int}`: New path with swapped point 

"""
function swap(path::Vector{Int}, x::Int, y::Int)::Vector{Int}
  swapped_path::Vector{Int} = copy(path)
  swapped_path[x], swapped_path[y] = swapped_path[y], swapped_path[x]
  return swapped_path
end

"""
Prepares move, function to calculate new path length, useless function

## Returns:
Tuple contatining:
- `swap:Function`: move swap
- `function`: function to calculate new path length
- `function`: new value 

"""
function moveSwap()::Tuple{Function, Function, Function}
  return (
    swap,
    function(path::Vector{Int}, move::Tuple{Int, Int, Float64}, weights::Matrix{Float64})
      x::Int, y::Int, distance::Float64 = move

      nodes::Int = size(weights, 1)
      prev_x::Int = x - 1 == 0 ? nodes : x - 1
      prev_y::Int = y - 1 == 0 ? nodes : y - 1
      next_x::Int = x + 1 > nodes ? 1 : x + 1
      next_y::Int = y + 1 > nodes ? 1 : y + 1
      result::Float64 = distance
      
      if (x == 1 && y == nodes) # Edge case
        result -= weights[path[y], path[next_x]]
        result -= weights[path[prev_y], path[x]]
        
        result += weights[path[x], path[next_x]]
        result += weights[path[prev_y], path[y]]
      elseif (abs(x - y) == 1)
        result -= weights[path[prev_x], path[y]]
        result -= weights[path[x], path[next_y]]

        result += weights[path[prev_x], path[x]]
        result += weights[path[y], path[next_y]]
      else
        result -= weights[path[prev_x], path[y]]
        result -= weights[path[y], path[next_x]]
        result -= weights[path[prev_y], path[x]]
        result -= weights[path[x], path[next_y]]

        result += weights[path[prev_y], path[y]]
        result += weights[path[y], path[next_y]]
        result += weights[path[prev_x], path[x]]
        result += weights[path[x], path[next_x]]
      end

      @assert result == nodeWeightSum(path, weights)
      return result
    end,
    function(i::Int) return i + 1 end
  )
end

"""
Inserts path[x] after path[y]

## Params:
- `path::Vector{Int}`: Path that we make invert on
- `x::Int`: First position in path
- `y::Int`: Second position in path

## Returns:
- `path::Vector{Int}`: New path after insertion

"""
function insert(path::Vector{Int}, x::Int, y::Int)::Vector{Int}
  inserted_path::Vector{Int} = copy(path)
  inserted_el::Int = inserted_path[x] 
  deleteat!(inserted_path, x)
  insert!(inserted_path, y, inserted_el)
  return inserted_path
end

"""
Prepares move, function to calculate new path length, useless function

## Returns:
Tuple contatining:
- `insert:Function`: move invert
- `function`: function to calculate new path length
- `function`: new value 

"""
function moveInsert()::Tuple{Function, Function, Function}
  return (
    insert,
    function(path::Vector{Int}, move::Tuple{Int, Int, Float64}, weights::Matrix{Float64})
      x::Int, y::Int, distance::Float64 = move
      
      nodes::Int = size(weights, 1)
      if (x == 1 && y == nodes) return distance end # Edge case, everything should stay the same
      prev_x::Int = x == 1 ? nodes : x - 1
      prev_y::Int = y == 1 ? nodes : y - 1
      next_y::Int = y == nodes ? 1 : y + 1

      result::Float64 = distance
      
      result -= weights[path[prev_x], path[y]]
      result -= weights[path[y], path[x]]
      result -= weights[path[prev_y], path[next_y]]

      result += weights[path[prev_x], path[x]]
      result += weights[path[prev_y], path[y]]
      result += weights[path[y], path[next_y]]

      @assert result == nodeWeightSum(path, weights)
      return result
    end,
    function(i::Int) return i + 1 end
  )
end

"""
    range_split(nodes)

A helper function splitting an integer range ranging from 1 to nodes evenly, based on current number of nodes assigned to Julia's REPL.
It is used to properly assign checked neighbourhood range for each thread, so we can parallelize everything properly.

# Params:

- `nodes::Int` - number of nodes for given TSP dataset.

# Returns:

- `Vector{Tuple{Int, Int}}` - a vector of evenly split integer range ranging from 1 to nodes based on current number of threads.

For example, if we want to split an integer range from 1 to 10 and we've assigned 2 threads to run this program, this function would return two even ranges for each thread: (1,5) and (6,10)
"""
function range_split(nodes::Int)::Vector{Tuple{Int, Int}}
  threads::Int = Threads.nthreads()
  splits::Int = cld(nodes, threads)
  if (splits == 0) return Vector{Tuple{Int, Int}}([(1,nodes)]) end
  return Vector{Tuple{Int, Int}}(
    [
      if (i+splits < nodes) 
        Tuple{Int,Int}((i+1,i+splits)) 
      else 
        Tuple{Int,Int}((i+1, nodes)) 
      end 
      for i in 0:splits:nodes-1
    ]
  )
end