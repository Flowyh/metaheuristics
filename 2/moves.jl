# move_funcs -> (function move(), function distance()) ? zeby mozna bylo latwo akcelerowac
# a jak nie to zwroci (function move(), nodeWeightSum)

function invert(path, x, y)
  inverted_path = copy(path)
  inverted_path[x:y] = inverted_path[y:-1:x]
  return inverted_path
end

function moveInvert()
  return (
    invert,
    function(path, move, weights)
      x, y, distance = move

      nodes = size(weights, 1)
      if (x == 1 && y == nodes) return distance end # Edge case, everything should stay the same
      prev_x = x - 1 == 0 ? nodes : x - 1
      next_y = y + 1 > nodes ? 1 : y + 1
      
      result = distance
      result -= weights[path[prev_x], path[y]]
      result -= weights[path[x], path[next_y]] 
      result += weights[path[prev_x], path[x]]
      result += weights[path[y], path[next_y]]
      
      # @assert result == nodeWeightSum(path, weights)
      return result
    end
  )
end

function swap(path, x, y)
  swapped_path = copy(path)
  swapped_path[x], swapped_path[y] = swapped_path[y], swapped_path[x]
  return swapped_path
end

function moveSwap()
  return (
    swap,
    function(path, move, weights)
      x, y, distance = move

      nodes = size(weights, 1)
      prev_x = x - 1 == 0 ? nodes : x - 1
      prev_y = y - 1 == 0 ? nodes : y - 1
      next_x = x + 1 > nodes ? 1 : x + 1
      next_y = y + 1 > nodes ? 1 : y + 1
      result = distance
      
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
    end
  )
end

function insert(path, x, y)
  inserted_path = copy(path)
  inserted_el = inserted_path[x] 
  deleteat!(inserted_path, x)
  insert!(inserted_path, y, inserted_el)
  return inserted_path
end

function moveInsert()
  return (
    insert,
    function(path, move, weights)
      x, y, distance = move
      
      nodes = size(weights, 1)
      if (x == 1 && y == nodes) return distance end # Edge case, everything should stay the same
      prev_x = x == 1 ? nodes : x - 1
      prev_y = y == 1 ? nodes : y - 1
      next_y = y == nodes ? 1 : y + 1

      result = distance
      
      result -= weights[path[prev_x], path[y]]
      result -= weights[path[y], path[x]]
      result -= weights[path[prev_y], path[next_y]]

      result += weights[path[prev_x], path[x]]
      result += weights[path[prev_y], path[y]]
      result += weights[path[y], path[next_y]]

      # @assert result == nodeWeightSum(path, weights)
      return result
    end
  )
end