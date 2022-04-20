module TabuSearch
  using TimesDates

  export move_invert
  export tabuSearch
  export twoopt, nearestNeighbour, repetitiveNearestNeighbour, nodeWeightSum
  export openTSPFile, structToDict

  # DONE:
  # 1 Implementacja deterministyczna/probabilistyczna
  # 5 Struktura, długość i sposób obsługi pamięci krótkoterminowej - lista tabu + matrix
  
  # TODO:
  # 2 Wyboru rozwiązania początkowego (Hubert)
  # 3 Definicji sąsiedztwa (ruchu) (Hubert - funkcje move, ja - funkcje distance)
  # 8 Warunek stopu algorytmu (Ja)
  
  # 4 Sposób przeglądu sąsiedztwa = wygeneruj ruch, jesli ruch w memory, skip, jesli nie, liczymy obj, przy okazji sprawdzamy z 8 watkow na raz
  # 6 Pamięć długoterminowa - wybieranie lepszych popraw? (razem)
  # 7 Wykrywanie cykli/stagnacji + mechanizm resetów/powrotów - jak 100 razy to samo, to wracamy (6) (razem)

  # 9/10 Optymalizacje kodu/wielowatkowosc - Julia moment (razem)

  debug = true
  function printDebug(str::String)
    if (debug) println(str) end
  end

  function tabuSearch(
    initial_path::Vector{Int},
    nodes::Int,
    weights::AbstractMatrix{Float64},
    move_funcs::Function,
    stop_criterion::Function,
    tabu_size::Int
  )
    tabu_list::Array{Tuple{Int, Int}} = [(-1, -1) for i in 1:tabu_size]
    tabu_matrix::Vector{BitVector} = [BitVector([0 for _ in 1:nodes]) for _ in 1:nodes]
    
    global_path::Vector{Int} = copy(initial_path) 
    
    (move, distance) = move_funcs()
    # (stop_stat, stop_check, updateStopStat!) = stop_criterion()

    n = 1
    the_bestest_path::Vector{Int} = copy(global_path)
    the_bestest_distance::Float64 = nodeWeightSum(the_bestest_path, weights)
    while (true)
      if (n == 5000) return the_bestest_path, the_bestest_distance end
      # updateStopStat!(stop_stat)
      # if (stop_check(stop_stat)) return the_bestest_path end
      local_path::Vector{Int} = copy(global_path)
      local_distance::Float64 = typemax(Float64)
      
      # Generate neighbours (2opt)
      for i in 1:nodes - 1, j in i+1:nodes
        if (tabu_matrix[i][j]) continue end # If tabu, skip
        current_path = move(local_path, i, j)
        @assert isperm(current_path)
        current_distance = distance(local_path, current_path, weights)
        # If new neighbour is the best
        if (current_distance < local_distance && !(tabu_matrix[i][j])) # sanity_check
          local_distance = current_distance
          local_path = copy(current_path)
          # remove from tabu list
          untabu = popfirst!(tabu_list)
          if (untabu != (-1, -1)) # remove from tabu matrix
            tabu_matrix[untabu[1]][untabu[2]] &= false 
            tabu_matrix[untabu[2]][untabu[1]] &= false
          end
          # Add to tabu
          push!(tabu_list, (i, j))
          tabu_matrix[i][j] |= true
          tabu_matrix[j][i] |= true
        end
      end
      # Save local minimum for next iteration
      global_path = copy(local_path)
      printDebug("Best local: $local_distance")
      # If local minimum is better than blobal
      if (local_distance < the_bestest_distance)
        the_bestest_distance = local_distance
        the_bestest_path = copy(local_path)
        printDebug("BEST: $(the_bestest_distance)")
      end 
      n += 1
    end
  
    return the_bestest_path, the_bestest_distance
  end

  include("./moves.jl")
  include("./stopCriteria.jl")
  include("./tsplib.jl")
  include("../1/algorithms.jl")
end