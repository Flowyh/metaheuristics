const MOVES = [moveInsert, moveInvert, moveSwap]

function random_swarm(size::Int, args...)::Vector{Bee}
  swarm::Vector{Bee} = []
  for _ in 1:size
    random_move = MOVES[rand(1:length(MOVES))]
    (move, distance, _) = random_move()
    smol_bee = Bee(
      [], 
      0,
      0.0,
      move,
      distance 
    )
    push!(swarm, smol_bee)
  end
  return swarm
end

function single_swarm(size::Int, move_func::Function, args...)::Vector{Bee}
  (move, distance, _) = move_func()
  swarm::Vector{Bee} = [
    Bee([], 0, 0.0, move, distance) for _ in 1:size
  ]
  return swarm
end

const invert_swarm(size::Int, args...) = single_swarm(size, moveInvert)
const insert_swarm(size::Int, args...) = single_swarm(size, moveInsert)
const swap_swarm(size::Int, args...) = single_swarm(size, moveSwap)

function prepared_swarm(size::Int, swapCount::Int, invertCount::Int, insertCount::Int)::Vector{Bee}
  @assert 100 == swapCount + invertCount + insertCount
  swapSize = floor(swapCount/100 * size)
  invertSize = floor(invertCount/100 * size)
  insertSize = floor(insertCount/100 * size)
  swarm::Vector{Bee} = []
  for _ in 1:swapSize
    (move, distance, _) = moveSwap()
    smol_bee = Bee(
      [], 
      0,
      0.0,
      move,
      distance 
    )
    push!(swarm, smol_bee)
  end
  for _ in 1:invertSize
    (move, distance, _) = moveInvert()
    smol_bee = Bee(
      [], 
      0,
      0.0,
      move,
      distance 
    )
    push!(swarm, smol_bee)
  end
  for _ in 1:insertSize
    (move, distance, _) = moveInsert()
    smol_bee = Bee(
      [], 
      0,
      0.0,
      move,
      distance 
    )
    push!(swarm, smol_bee)
  end
  return swarm
end