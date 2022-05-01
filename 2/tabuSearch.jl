module TabuSearch
  using TimesDates
  using Random
  using FLoops

  export moveInvert, moveSwap, moveInsert
  export tabuSearch
  export krandom, twoopt, nearestNeighbour, repetitiveNearestNeighbour, nodeWeightSum
  export openTSPFile, structToDict
  export iterationsCriterion, timeCriterion

  # DONE:
  # 1 Implementacja deterministyczna/probabilistyczna
  # 5 Struktura, długość i sposób obsługi pamięci krótkoterminowej - lista tabu + matrix
  # 6 Pamięć długoterminowa - wybieranie lepszych popraw? (razem)
  # 4 Sposób przeglądu sąsiedztwa = wygeneruj ruch, jesli ruch w memory, skip, jesli nie, liczymy obj, przy okazji sprawdzamy z 8 watkow na raz
  # 8 Warunek stopu algorytmu (Ja)
  # 7 Wykrywanie cykli/stagnacji + mechanizm resetów/powrotów - jak 100 razy to samo, to wracamy (6) (razem)
  # Akceleracja inverta (proste)
  # Pamiec dlugoterminowa jako stack
  # 9/10 Optymalizacje kodu/wielowatkowosc - Julia moment (razem)

  # TODO:
  # 2 Wyboru rozwiązania początkowego i parametrow (CLI) (Hubert)
  # Funkcja do badań (Ja)
  # Typy badań (razem)
  # Ploty (Hubert)
  # Markdown (Ja)
  # Komentarze (Razem)
  # Cleanup (Razem)

  mutable struct MemoryCell
    solution::Vector{Int}
    move::Tuple{Int, Int}
    tabu_list::Array{Tuple{Int, Int}}
    tabu_matrix::Vector{BitVector}
  end

  debug = true
  function printDebug(str::String)
    if (debug) println(str) end
  end

  function range_split(nodes)::Vector{Tuple{Int, Int}}
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

  function tabuSearch(
    initial_path::Vector{Int},
    nodes::Int,
    weights::AbstractMatrix{Float64},
    moveFuncs::Function,
    stopCriterion::Function,
    tabu_size::Int,
    aspiration_threshold::Float64,
    backtrack_size::Int,
    stagnation_limit::Int
  )
    # Short-term memory
    tabu_list::Array{Tuple{Int, Int}} = [(-1, -1) for i in 1:tabu_size]
    tabu_matrix::Vector{BitVector} = [BitVector([0 for _ in 1:nodes]) for _ in 1:nodes]

    # Long-term memory
    backtrack_jump_list::Array{MemoryCell} = []

    # Move functions
    (move, distance, j_start) = moveFuncs()

    # Stop criterion functions
    (stop_stat, stopCheck, updateStopStat) = stopCriterion()

    # Starting point
    global_path::Vector{Int} = copy(initial_path)

    # Best solution
    the_bestest_path::Vector{Int} = copy(global_path)
    the_bestest_distance::Float64 = nodeWeightSum(the_bestest_path, weights)
    
    # Local solution
    local_path::Vector{Int} = copy(global_path)
    local_distance::Float64 = typemax(Float64)
    new_move::Tuple{Int, Int} = (-1, -1)

    # Stagnation
    stagnation = 0

    # Thread splits
    splits::Vector{Tuple{Int, Int}} = range_split(nodes)

    function search_neighbourhood(
      range::Tuple{Int, Int}, 
    )::Tuple{Vector{Int}, Float64, Tuple{Int, Int}}
      start::Int, s_end::Int = range
      dist::Float64 = typemax(Float64)
      mv::Tuple{Int, Int} = (-1, 1)
      for i in start:s_end, j in j_start(i):nodes
        if (i == j) continue end
        # Generate new path
        current_path::Vector{Int} = move(local_path, i, j)

        # If path is a proper permutation
        # @assert isperm(current_path)

        # Compute obj function
        if (dist == typemax(Float64)) current_distance::Float64 = nodeWeightSum(current_path, weights)
        else current_distance = distance(current_path, (i, j, dist), weights) end

        # Aspiration not satisfied
        if (tabu_matrix[i][j] && current_distance > the_bestest_distance * (1 - aspiration_threshold))
          continue
        end

        # If new neighbour is the best
        if (current_distance < dist) # sanity_check
          mv = (i, j)
          dist = current_distance
          local_path = copy(current_path)
        end
      end
      return (local_path, dist, mv)
    end

    while (true)
      stop_stat = updateStopStat(stop_stat)
      if (stopCheck(stop_stat)) return the_bestest_path, the_bestest_distance end

      # Parallel neighbourhood searching using FLoops.jl
      @floop for split in splits
        (tmp_path, tmp_distance, tmp_move) = search_neighbourhood(split)
        # Find minimal distance (thread-safe)
        @reduce() do (path = Vector{Int}(undef, 0); tmp_path) , (dist = typemax(Float64); tmp_distance) , (mv = (-1,-1); tmp_move)
          if (tmp_distance < dist)
            path = tmp_path
            dist = tmp_distance
            mv = tmp_move
          end
        end
      end
      # Assign found values
      (local_path, local_distance, new_move) = (path, dist, mv)

      local i, j = new_move

      # Remove from tabu list
      untabu = popfirst!(tabu_list)
      if (untabu != (-1, -1)) # remove from tabu matrix
        tabu_matrix[untabu[1]][untabu[2]] &= false
        tabu_matrix[untabu[2]][untabu[1]] &= false
      end

      # Add to tabu
      push!(tabu_list, (i, j))
      tabu_matrix[i][j] |= true
      tabu_matrix[j][i] |= true

      # Check for stagnation, backtrack if necessary
      if (stagnation > stagnation_limit)
        if (length(backtrack_jump_list) > 0)
          printDebug("STAGNATION")
          backtrack_cell = pop!(backtrack_jump_list)
          global_path = backtrack_cell.solution
          tabu_list = backtrack_cell.tabu_list
          tabu_matrix = backtrack_cell.tabu_matrix
        else
          printDebug("RESET")
          # printDebug("Tabu: $tabu_list")
          global_path = initial_path
        end
        stagnation = 0
        continue
      end

      # Save local minimum for next iteration
      global_path = copy(local_path)
      # printDebug("Best local: $local_distance")

      # If local minimum is better than global
      if (local_distance < the_bestest_distance)
        the_bestest_distance = local_distance
        the_bestest_path = copy(local_path)
        printDebug("BEST: $(the_bestest_distance)")

        # Add long-term memory cell
        NewMemoryCell = MemoryCell(local_path, new_move, tabu_list, tabu_matrix)
        push!(backtrack_jump_list, NewMemoryCell)

        # If backtrack memory size exceeded
        if (length(backtrack_jump_list) > backtrack_size)
          popfirst!(backtrack_jump_list)
        end

        # Reset stagnation counter
        stagnation = 0
      else
        # Increment stagnation counter
        stagnation += 1
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
