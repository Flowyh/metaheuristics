  const MOVES = [moveInsert, moveInvert, moveSwap]

  function random_swarm(size::Int)::Vector{Bee}
    swarm::Vector{Bee} = []
    for _ in 1:size
      random_move = MOVES[rand(1:length(MOVES))]
      (move, distance, _) = random_move()
      smol_bee = Bee(
        [], 
        0.0,
        move,
        distance 
      )
      push!(swarm, smol_bee)
    end
    return swarm
  end

  function invert_swarm(size::Int)::Vector{Bee}
    swarm::Vector{Bee} = []
    for _ in 1:size
      (move, distance, _) = moveInvert()
      smol_bee = Bee(
        [], 
        0.0,
        move,
        distance 
      )
      push!(swarm, smol_bee)
    end
    return swarm
  end