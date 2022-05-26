module ArtificialBeeColony

  include("../1/algorithms.jl")
  include("../2/stopCriteria.jl")
  include("../2/moves.jl")
  include("../2/tsplib.jl")
  include("./swarms.jl")

  export beeror
  export Bee, random_swarm, invert_swarm, produce_honey
  export openTSPFile, structToDict
  export timeCriterion, iterationsCriterion
  export nodeWeightSum

  function beerror()
    throw("https://www.tiktok.com/@steves_monologue/video/7098949151240736046?is_copy_url=1&is_from_webapp=v1")
  end

  # Just a debugging print, nothing interesting.
  debug = true
  function printDebug(str::String)
    if (debug) println(str) end
  end

  mutable struct Bee #🐝
    flower::Vector{Int} #🌸 Current solution
    nectar::Float64 #🍯 Objective function value
    fly::Function # Move
    wings::Function #💸 Accelerated distance
  end

  using Random, StatsBase

  # Roulette wheel selection using stochastic acceptance (http://www.sciencedirect.com/science/article/pii/S0378437111009010)
  function stochastic_rws(weights::Vector{Float64})
    min = minimum(weights)
    while true
      i = rand(1:length(weights))
      if (rand() < min / weights[i])
        return i
      end
    end
  end

  function produce_honey(
    meadow::AbstractMatrix{Float64}, 
    flower_size::Int, 
    hive::Vector{Bee}, 
    nectar_estimator::Function, 
    flower_visits_limit::Int, 
    stopCriterion::Function
  )
    beest_flower::Vector{Int} = shuffle(collect(1:flower_size))
    beest_nectar::Float64 = nectar_estimator(beest_flower, meadow)
    flower_visits::Vector{Int} = zeros(length(hive))

    hive[1].flower = beest_flower # First bee
    hive[1].nectar = beest_nectar

    # Bee hatchery
    for bee in hive
      bee.flower::Vector{Int} = shuffle(collect(1:flower_size))
      bee.nectar::Float64 = nectar_estimator(bee.flower, meadow)
      if (bee.nectar < beest_nectar)
        beest_flower = copy(bee.flower)
        beest_nectar = bee.nectar
      end  
    end

    # Stop criterion functions
    (stop_stat, stopCheck, updateStopStat) = stopCriterion()

    # Honey production
    while (true)
      stop_stat = updateStopStat(stop_stat)
      if (stopCheck(stop_stat)) return beest_flower, beest_nectar end
      println("Stat: $stop_stat")

      # printDebug("Employees working . . .")
      for (beendex, employee_bee) in enumerate(hive) #💼
        old_flower::Vector{Int} = copy(employee_bee.flower)
        old_nectar::Float64 = employee_bee.nectar
        # New neighbouring flower
        (x, y) = sample(1:flower_size, 2, replace=false)
        new_flower::Vector{Int} = employee_bee.fly(old_flower, x, y)
        # new_nectar::Float64 = employee_bee.wings(new_flower, (x, y, old_nectar), meadow)
        new_nectar::Float64 = nectar_estimator(new_flower, meadow)
        
        if (new_nectar < old_nectar)
          flower_visits[beendex] = 0
          employee_bee.flower = new_flower
          employee_bee.nectar = new_nectar
          if (employee_bee.nectar < beest_nectar)
            beest_flower = copy(employee_bee.flower)
            beest_nectar = employee_bee.nectar
            printDebug("Beest: $beest_nectar $stop_stat")
          end
        else
          flower_visits[beendex] += 1
        end
      end

      # printDebug("Onlookers looking . . . ")
      nectars = [bee.nectar for bee in hive]
      for (beendex, onlooker_bee) in enumerate(hive) #👀
        # Choose one good bee
        j = stochastic_rws(nectars)
        chosen_bee = hive[j]
        old_flower::Vector{Int} = copy(chosen_bee.flower)
        old_nectar::Float64 = chosen_bee.nectar
        # New neighbouring flower
        (x, y) = sample(1:flower_size, 2, replace=false)
        new_flower::Vector{Int} = onlooker_bee.fly(old_flower, x, y)
        # new_nectar::Float64 = onlooker_bee.wings(new_flower, (x, y, old_nectar), meadow)
        new_nectar::Float64 = nectar_estimator(new_flower, meadow)
        if (new_nectar < old_nectar)
          flower_visits[beendex] = 0
          onlooker_bee.flower = new_flower
          onlooker_bee.nectar = new_nectar
          if (onlooker_bee.nectar < beest_nectar)
            beest_flower = copy(onlooker_bee.flower)
            beest_nectar = onlooker_bee.nectar
            printDebug("Beest: $beest_nectar $stop_stat")
          end
        else
          flower_visits[beendex] += 1
        end
      end

      # printDebug("Scouts scouting . . . ")
      for (beendex, scout_bee) in enumerate(hive) #⚜️
        if (flower_visits[beendex] > flower_visits_limit)
          # printDebug("This flower is disgusteng")
          scout_bee.flower = shuffle(collect(1:flower_size))
          flower_visits[beendex] = 0
          scout_bee.nectar = nectar_estimator(scout_bee.flower, meadow)
          if (scout_bee.nectar < beest_nectar)
            beest_flower = copy(scout_bee.flower)
            beest_nectar = scout_bee.nectar
            printDebug("Beest: $beest_nectar $stop_stat")
          end
        end
      end
      # println("Current beest: $(beest_nectar)!")
    end
    return beest_flower, beest_nectar
  end
end