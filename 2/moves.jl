# move_funcs -> (function move(), function distance(), function j_start()) ? zeby mozna bylo latwo akcelerowac
# a jak nie to zwroci (function move(), nodeWeightSum)

function invert(path::Vector{Int}, x::Int, y::Int)::Vector{Int}
  inverted_path::Vector{Int} = copy(path)
  inverted_path[x:y] = inverted_path[y:-1:x]
  return inverted_path
end

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
      
      # @assert result == nodeWeightSum(path, weights)
      return result
    end,
    function(i::Int) return i + 1 end
  )
end

function swap(path::Vector{Int}, x::Int, y::Int)::Vector{Int}
  swapped_path::Vector{Int} = copy(path)
  swapped_path[x], swapped_path[y] = swapped_path[y], swapped_path[x]
  return swapped_path
end

function moveSwap()::Tuple{Function, Function, Function}
  return (
    swap,
    function(path::Vector{Int}, move::Tuple{Int, Int, Float64}, weights::Matrix{Float64})
      x::Int, y::Int, distance::Float64 = move

      nodes::Int = size(weights, 1)::Float64
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

      # @assert result == nodeWeightSum(path, weights)
      return result
    end,
    function(i::Int) return i + 1 end
  )
end

function insert(path::Vector{Int}, x::Int, y::Int)::Vector{Int}
  inserted_path::Vector{Int} = copy(path)
  inserted_el::Int = inserted_path[x] 
  deleteat!(inserted_path, x)
  insert!(inserted_path, y, inserted_el)
  return inserted_path
end

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

      # @assert result == nodeWeightSum(path, weights)
      return result
    end,
    function(i::Int) return i + 1 end
  )
end