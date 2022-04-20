module TabooSearch
  using TimesDates
  using Random

  export move_invert
  export tabooSearch
  export twoopt, nearestNeighbour, repetitiveNearestNeighbour, nodeWeightSum
  export openTSPFile, structToDict
  export addAspiration, mulAspiration
  export iterationsCriterion, timeCriterion

  # DONE:
  # 1 Implementacja deterministyczna/probabilistyczna
  # 5 Struktura, długość i sposób obsługi pamięci krótkoterminowej - lista taboo + matrix
  # 6 Pamięć długoterminowa - wybieranie lepszych popraw? (razem)
  # 4 Sposób przeglądu sąsiedztwa = wygeneruj ruch, jesli ruch w memory, skip, jesli nie, liczymy obj, przy okazji sprawdzamy z 8 watkow na raz
  # 8 Warunek stopu algorytmu (Ja)
  # 7 Wykrywanie cykli/stagnacji + mechanizm resetów/powrotów - jak 100 razy to samo, to wracamy (6) (razem)
  
  # TODO
  # 2 Wyboru rozwiązania początkowego (Hubert)
  # 3 Definicji sąsiedztwa (ruchu) (Hubert - funkcje move, ja - funkcje distance)
  
  # 9/10 Optymalizacje kodu/wielowatkowosc - Julia moment (razem)

  debug = true
  function printDebug(str::String)
    if (debug) println(str) end
  end

  function tabooSearch(
    initial_path::Vector{Int},
    nodes::Int,
    weights::AbstractMatrix{Float64},
    move_funcs::Function,
    stop_criterion::Function,
    taboo_size::Int,
    aspiration_update::Function,
    aspiration_inc::Float64,
    aspiration_dec::Float64,
    occurence_threshold::Int
  )
    # Short-term memory
    taboo_list::Array{Tuple{Int, Int}} = [(-1, -1) for i in 1:taboo_size]
    taboo_matrix::Vector{BitVector} = [BitVector([0 for _ in 1:nodes]) for _ in 1:nodes]

    # Long-term memory
    solultions = Dict()

    # Aspiration
    aspiration = 0.0

    # Move functions
    (move, distance) = move_funcs()

    # Stop criterion functions
    (stop_stat, stop_check, updateStopStat) = stop_criterion()

    # Starting point
    global_path::Vector{Int} = copy(initial_path)
    # Best solution
    the_bestest_path::Vector{Int} = copy(global_path)
    the_bestest_distance::Float64 = nodeWeightSum(the_bestest_path, weights)
    while (true)
      stop_stat = updateStopStat(stop_stat)
      if (stop_check(stop_stat)) return the_bestest_path, the_bestest_distance end
      local_path::Vector{Int} = copy(global_path)
      local_distance::Float64 = typemax(Float64)
      new_move::Tuple{Int, Int} = (-1, -1)
      
      # Generate neighbours (2opt)
      for i in 1:nodes - 1, j in i+1:nodes
        # If taboo and not enough aspiration, skip
        # If picked taboo with enough aspiration, reset aspiration
        if (taboo_matrix[i][j]) 
          if (rand() > aspiration)
            continue
          else
            aspiration = 0.0
          end
        end
        # Generate new path
        current_path = move(local_path, i, j)
        # Check for long-term memory occurences
        if (haskey(solultions, current_path))
          if (solultions[current_path] > occurence_threshold)
            println("SHUFFLE!")
            shuffle!(global_path)
            break
          else
            solultions[current_path] += 1
          end
        else solultions[current_path] = 1 end
        # If path is a proper permutation
        @assert isperm(current_path)
        current_distance = distance(current_path, (i, j), weights)
        # If new neighbour is the best
        if (current_distance < local_distance) # sanity_check
          new_move = (i, j)
          local_distance = current_distance
          local_path = copy(current_path)
        end
      end
      # If we found a better move (didn't shuffle)
      if (new_move != (-1, -1))
        local i, j = new_move
        # remove from taboo list
        untaboo = popfirst!(taboo_list)
        if (untaboo != (-1, -1)) # remove from taboo matrix
          taboo_matrix[untaboo[1]][untaboo[2]] &= false 
          taboo_matrix[untaboo[2]][untaboo[1]] &= false
        end
        # Add to taboo
        push!(taboo_list, (i, j))
        taboo_matrix[i][j] |= true
        taboo_matrix[j][i] |= true
        # Save local minimum for next iteration
        global_path = copy(local_path)
        printDebug("Best local: $local_distance")
        # If local minimum is better than blobal
        if (local_distance < the_bestest_distance)
          the_bestest_distance = local_distance
          the_bestest_path = copy(local_path)
          printDebug("BEST: $(the_bestest_distance)")
          aspiration = aspiration_update(aspiration, aspiration_dec)
        else
          aspiration = aspiration_update(aspiration, aspiration_inc)
        end
      end
    end
  
    return the_bestest_path, the_bestest_distance
  end

  include("./moves.jl")
  include("./stopCriteria.jl")
  include("./tsplib.jl")
  include("../1/algorithms.jl")
  include("./aspiration.jl")
end