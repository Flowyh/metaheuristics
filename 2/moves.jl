# move_funcs -> (function move(), function distance()) ? zeby mozna bylo latwo akcelerowac
# a jak nie to zwroci (function move(), nodeWeightSum)

function invert(path, x, y)
  inverted_path = copy(path)
  inverted_path[x:y] = inverted_path[y:-1:x]
  return inverted_path
end

function move_invert()
  return (
    invert,
    function(path, move, weights)
      x, y, distance = move
      nodeWeightSum(path, weights)
    end
  )
end

function swap(path, x, y)
  swapped_path = copy(path)
  swapped_path[x], swapped_path[y] = swapped_path[y], swapped_path[x]
  return swapped_path
end

function move_swap()
  return (
    swap,
    function(path, move, weights)
      x, y, distance = move
      if (x > y) x , y = y, x end
      if (x > 1)
        distance -= weights[x-1][x]
        distance += weights[x-1][y]
      end
      if (x+1 != y)
        distance -= weights[x][x+1]
        distance += weights[y][x+1]
        distance -= weights[y-1][y]
        distance += weights[y-1][x]
      end
      if (y < length(path))
        distance -= weights[y][y+1]
        distance += weights[x][y+1]
      end
      return distance
    end
  )
end
