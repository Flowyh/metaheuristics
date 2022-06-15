module ArtificialBeeColony

  using Random, StatsBase, FLoops

  include("../1/algorithms.jl")
  include("../2/stopCriteria.jl")
  include("../2/moves.jl")
  include("../2/tsplib.jl")
  include("./swarms.jl")
  include("./selection.jl")

  export beeror, setDebug
  export Bee, random_swarm, invert_swarm, insert_swarm, swap_swarm, prepared_swarm, produce_honey
  export openTSPFile, structToDict
  export timeCriterion, iterationsCriterion
  export nodeWeightSum, krandom, twoopt, nearestNeighbour, repetitiveNearestNeighbour
  export moveInsert, moveInvert, moveSwap
  export stochastic_rws, tournament

  function beerror()
    throw("https://www.tiktok.com/@steves_monologue/video/7098949151240736046?is_copy_url=1&is_from_webapp=v1")
  end

  # Just a debugging print, nothing interesting.
  debug = true
  function printDebug(str::String)
    if (debug) println(str) end
  end
  function setDebug(flag::Bool)
    global debug = flag
  end

  mutable struct Bee #🐝
    flower::Vector{Int} #🌸 Current solution
    flower_visits::Int #💼 Number of flights to current solution
    nectar::Float64 #🍯 Objective function value
    fly::Function #✈️ Move
    wings::Function #💸 Accelerated distance
  end

  function find_best_bee(bees::Vector{Bee})::Bee
    return reduce((x, y) -> x.nectar < y.nectar ? x : y, bees)
  end

  function employee_bees(e_bees::Vector{Bee}, meadow::AbstractMatrix{Float64}, flower_size::Int, nectar_estimator::Function)::Tuple{Vector{Int}, Float64}
    e_nectar::Float64 = typemax(Float64)
    e_flower::Vector{Int} = e_bees[1].flower

    for employee_bee in e_bees
      old_flower::Vector{Int} = copy(employee_bee.flower)
      old_nectar::Float64 = employee_bee.nectar
      # New neighbouring flower
      (x, y) = sample(1:flower_size, 2, replace=false)
      new_flower::Vector{Int} = employee_bee.fly(old_flower, x, y)
      new_nectar::Float64 = nectar_estimator(new_flower, meadow)
      if (new_nectar < old_nectar)
        employee_bee.flower_visits = 0
        employee_bee.flower = new_flower
        employee_bee.nectar = new_nectar
        if (new_nectar < e_nectar)
          e_flower = new_flower
          e_nectar = new_nectar
        end
      else
        employee_bee.flower_visits += 1
      end
    end
    
    return (e_flower, e_nectar)
  end

  function onlooker_bee(chosen_bee::Bee, follower_bees::Vector{Bee}, meadow::AbstractMatrix{Float64}, flower_size::Int, nectar_estimator::Function)::Tuple{Vector{Int}, Float64}
    o_nectar::Float64 = chosen_bee.nectar
    o_flower::Vector{Int} = chosen_bee.flower
    
    for onlooker_bee in follower_bees 
      old_flower::Vector{Int} = copy(chosen_bee.flower)
      old_nectar::Float64 = chosen_bee.nectar
      # New neighbouring flower
      (x, y) = sample(1:flower_size, 2, replace=false)
      new_flower::Vector{Int} = onlooker_bee.fly(old_flower, x, y)
      new_nectar::Float64 = nectar_estimator(new_flower, meadow)
      if (new_nectar < old_nectar)
        onlooker_bee.flower_visits = 0
        onlooker_bee.flower = new_flower
        onlooker_bee.nectar = new_nectar
        if (new_nectar < o_nectar)
          o_flower = new_flower
          o_nectar = new_nectar
        end
      else
        onlooker_bee.flower_visits += 1
      end
    end

    return (o_flower, o_nectar)
  end
  
  function select_bees(bees::Vector{Bee}, selection::Function, selection_param::Float64)::Dict{Bee, Vector{Bee}}
    chosen_bees::Dict{Bee, Vector{Bee}} = Dict()
    nectars::Vector{Float64} = [bee.nectar for bee in bees]
    for _ in bees
      # Choose one good bee
      j = selection(nectars, selection_param)
      selected_good_bee = bees[j]
      if (!haskey(chosen_bees, selected_good_bee))
        chosen_bees[selected_good_bee] = [selected_good_bee]
      else
        push!(chosen_bees[selected_good_bee], selected_good_bee)
      end
    end

    return chosen_bees
  end

  function scouts_bees(s_bees::Vector{Bee}, flower_visits_limit::Int, meadow::AbstractMatrix{Float64}, flower_size::Int, nectar_estimator::Function)::Tuple{Vector{Int}, Float64}
    s_nectar::Float64 = typemax(Float64)
    s_flower::Vector{Int} = s_bees[1].flower

    for scout_bee in s_bees
      if (scout_bee.flower_visits > flower_visits_limit)
        # printDebug("This flower is disgusteng")
        scout_bee.flower = shuffle(collect(1:flower_size))
        scout_bee.flower_visits = 0
        scout_bee.nectar = nectar_estimator(scout_bee.flower, meadow)
        if (scout_bee.nectar < s_nectar)
          s_flower = copy(scout_bee.flower)
          s_nectar = scout_bee.nectar
        end
      end
    end

    return (s_flower, s_nectar)
  end

  function produce_honey(
    meadow::AbstractMatrix{Float64}, 
    flower_size::Int, 
    hive::Vector{Bee}, 
    nectar_estimator::Function, 
    flower_visits_limit::Int, 
    stopCriterion::Function,
    selection::Function,
    selection_param::Float64
  )
    beest_flower::Vector{Int} = shuffle(collect(1:flower_size))
    beest_nectar::Float64 = nectar_estimator(beest_flower, meadow)

    hive[1].flower = beest_flower # First bee
    hive[1].nectar = beest_nectar

    # Bee hatchery
    @floop for bee in hive
      bee.flower::Vector{Int} = shuffle(collect(1:flower_size))
      bee.nectar::Float64 = nectar_estimator(bee.flower, meadow)  
    end

    best_bee::Bee = find_best_bee(hive)

    if (best_bee.nectar < beest_nectar)
      beest_flower = copy(best_bee.flower)
      beest_nectar = best_bee.nectar
    end

    # Stop criterion functions
    (stop_stat, stopCheck, updateStopStat) = stopCriterion()

    # FLoops ranges
    ranges = range_split(length(hive))

    # Honey production
    while (true)
      stop_stat = updateStopStat(stop_stat)
      if (stopCheck(stop_stat)) return beest_flower, beest_nectar end
      # println("Stat: $stop_stat")

      # printDebug("Employees working . . .")
      @floop for (i, j) in ranges #👨‍💼
        (fl_e_flower, fl_e_nectar) = employee_bees(hive[i:j], meadow, flower_size, nectar_estimator)
        @reduce() do (e_f = Vector{Int}(undef, 0); fl_e_flower), (e_n = typemax(Float64); fl_e_nectar)
          if (fl_e_nectar < e_n)
            e_f = fl_e_flower
            e_n = fl_e_nectar
          end
        end
      end

      # best_bee = find_best_bee(hive)
      if (e_n < beest_nectar)
        beest_flower = copy(e_f)
        beest_nectar = e_n
        printDebug("Beest: $beest_nectar")
      end

      # printDebug("Onlookers looking . . . ")
      selected_bees::Dict{Bee, Vector{Bee}} = select_bees(hive, selection, selection_param)

      @floop for bee in keys(selected_bees) #👀
        (fl_o_flower, fl_o_nectar) = onlooker_bee(bee, selected_bees[bee], meadow, flower_size, nectar_estimator)
        @reduce() do (o_f = Vector{Int}(undef, 0); fl_o_flower), (o_n = typemax(Float64); fl_o_nectar)
          if (fl_o_nectar < o_n)
            o_f = fl_o_flower
            o_n = fl_o_nectar
          end
        end
      end

      # best_bee = find_best_bee(hive)
      if (o_n < beest_nectar)
        beest_flower = copy(o_f)
        beest_nectar = o_n
        printDebug("Beest: $beest_nectar")
      end

      # printDebug("Scouts scouting . . . ")

      @floop for (i, j) in ranges #⚜️
        (fl_s_flower, fl_s_nectar) = scouts_bees(hive[i:j], flower_visits_limit, meadow, flower_size, nectar_estimator)
        @reduce() do (s_f = Vector{Int}(undef, 0); fl_s_flower), (s_n = typemax(Float64); fl_s_nectar)
          if (fl_s_nectar < s_n)
            s_f = fl_s_flower
            s_n = fl_s_nectar
          end
        end
      end

      # best_bee = find_best_bee(hive)
      if (s_n < beest_nectar)
        beest_flower = copy(s_f)
        beest_nectar = s_n
        printDebug("Beest: $beest_nectar")
      end
      # println("Current beest: $(beest_nectar)!")
    end
    return beest_flower, beest_nectar
  end
end