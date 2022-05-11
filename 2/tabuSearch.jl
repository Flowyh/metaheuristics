module TabuSearch
  using TimesDates
  using Random
  using FLoops

  export moveInvert, moveSwap, moveInsert
  export tabuSearch
  export krandom, twoopt, nearestNeighbour, repetitiveNearestNeighbour, nodeWeightSum
  export openTSPFile, structToDict
  export iterationsCriterion, timeCriterion

  """
  An instance of long-term memory unit in tabu search.
  Essentially, it's an object storing current solution, tabu list (and it's matrix) and move leading to given solution (currently unused).

  # Params: 
  
  - `solution::Vector{Int}` - chosen path for given TSP dataset,
  - `move::Tuple{Int, Int}` - move arguments leading to given solution,
  - `tabu_list::Array{Tuple{Int, Int}}` - list of forbidden moves for given solution,
  - `tabu_matrix::Vector{BitVector}` - matrix of all possible moves for current TSP dataset with marked tabu moves (needed for O(1) lookup time).
  
  """
  mutable struct MemoryCell
    solution::Vector{Int}
    move::Tuple{Int, Int}
    tabu_list::Array{Tuple{Int, Int}}
    tabu_matrix::Vector{BitVector}
  end

  # Just a debugging print, nothing interesting.
  debug = true
  function printDebug(str::String)
    if (debug) println(str) end
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

  """
      tabuSearch(initial_path, nodes, weights, moveFuncs, stopCriterion, tabu_size, aspiration_threshold, backtrack_size, stagnation_limit)

  Our implementation of Tabu Search heuristic.

  It meets all the requirements provided at the task descrpition:
  1. It is fully deterministic.
  2. An external CLI is provided to setup all parameters and choose a starting solution (initial_path).
  3. Fully compatibile with 3 different move types (moveFuncs): insert, invert and swap.
  4. Proper neighbourhood searching logic.
  5. Tabu list implementation + tabu list lookup time in O(1).
  6. Long-term memory and proper backtracking.
  7. Stagnation detection based on number of not improving iteartions.
  8. Stop criteria based on elapsed time or number of iterations (stopCriterion).
  9. Acceleration of insert, invert and swap, tabu list lookup in O(1), some minor Julia performance improvements.
  10. Parallel neighbourhood searching.

  We've also implemented an aspiration mechanism, which lets banned moves to be picked, only if they would lead us to the path that is better than (1 - aspiration_threshold) * 100% of best possible solution so far.

  # Params:

  - `initial_path::Vector{Int}` - initial solution of current TSP dataset as vector of nodes' indexes,
  - `nodes::Int` - number of nodes in current TSP dataset,
  - `weights::AbstractMatrix{Float64}` - a matrix of weights between current TSP dataset's nodes,
  - `moveFuncs::Function` - a generic functions wrapper describing one of possible moves: swap, insert and invert, see moves.jl for more information,
  - `stopCriterion::Function` -  a generic functions wrapper describing stop critiera for Tabu Search heuristic, see stopCriteria.jl for more information,
  - `tabu_size::Int` - size of tabu list in Tabu Search heuristic,
  - `aspiration_threshold::Float64` - an error percentage used to let banned moves to be picked, if it improve our solution, see above,
  - `backtrack_size::Int` - size of long-term memory (backtrack list),
  - `stagnation_limit::Int` - number of iterations without improvement, after which we would have to backtrack to previous best solution (after which we know that we are stuck at local minimum).

  # Returns:

  - `Tuple{Float64, Vector{Int}}` - best computed TSP dataset objective function value and computed solution.

  """
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

    """
        search_neighbourhood(range)

    Perform neighbourhood seraching for Tabu Search heuristic on given range.

    Check every possible move for given range and return best found solution, objective function value and move that lead to that solution.

    # Params:

    - `range::Tuple{Int, Int}` - a range to be checked.

    # Returns:

    - `Tuple{Vector{Int}, Float64, Tuple{Int, Int}}` - best possible solution, it's objective function value and move that lead to this solution.

    """
    function search_neighbourhood(range::Tuple{Int, Int})::Tuple{Vector{Int}, Float64, Tuple{Int, Int}}
      start::Int, s_end::Int = range
      dist::Float64 = typemax(Float64)
      mv::Tuple{Int, Int} = (-1, 1)
      path::Vector{Int} = copy(local_path)
      for i in start:s_end, j in j_start(i):nodes
        if (i == j) continue end
        # Generate new path
        current_path::Vector{Int} = move(path, i, j)

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
          path = copy(current_path)
        end
      end
      return (path, dist, mv)
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
