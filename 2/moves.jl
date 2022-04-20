# move_funcs -> (function move(), function distance()) ? zeby mozna bylo latwo akcelerowac
# a jak nie to zwroci (function move(), nodeWeightSum)

function invert(path, x, y)
  inverted_path = [path...]
  inverted_path[x:y] = inverted_path[y:-1:x]
  return inverted_path
end

function move_invert()
  return (
    invert,
    function(path, move, weights)
      x, y = move
      nodeWeightSum(path, weights) # TODO: accelerate
    end
  )
end
