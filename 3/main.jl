include("./artificial_bee_colony.jl")
using .ArtificialBeeColony
include("../1/generate.jl")
include("./testing.jl")

export timeCriterion, iterationsCriterion

"""
Print usage
"""
function usage()
   println("""
   Usage: julia main.jl
   ARGS:
   1: path to TSP file or data type: ["hardcoded", "random"]
   2: number of bees
   3: stop criterion [time, iteration]
   4: stop criterion limit [seconds, number of iterations]
   5: flower visits limit [int]
   6: other funcs
   7: repeats (if mode == hardcoded or random) [uint]
   8: start number of nodes (if mode == random) [uint]
   9: step number of nodes (if mode == random) [uint]
   10: end number of nodes (if mode == random) [uint]
   11: random type [euclidean, assymetric]
   """)
end

"""
Main function that with certain arguments given, starts tabu search.
Args needed specified in usage function
"""
function main(args::Array{String})
  stopCriteria = Dict("time" => timeCriterion, "iteration" => iterationsCriterion)
  otherAlgs = Dict("krand" => krandom, "2opt" => twoopt, "nn" => nearestNeighbour, "rnn" => repetitiveNearestNeighbour, "tabu" => tabuSearch)

  if (length(ARGS) < 5)
    println("Please provide at least 5 arguments.")
    usage()
    exit(1)
  end
  if (lowercase(args[1]) == "help")
    usage()
    exit(1)    
  end
  try
    mode = args[1]
    bees_count = parse(Int, args[2])
    stopCriterion = stopCriteria[args[3]]
    stopCritAmount = parse(Int, args[4])
    visits_limit = parse(Int, args[5])
    other_funcs = Array{Function}([produce_honey, collect(values(otherAlgs))...])
    if (length(args) >= 6 && args[6] != "all")
      other_funcs = Array{Function}([produce_honey])
      funcs = split(args[6], ",")
      for func in funcs
        if (haskey(startingAlgs, func))
          push!(other_funcs, startingAlgs[func])
        end
      end
    end

    if (mode == "hardcoded")
      if (length(args) < 7)
        println("Please provide at least 11 arguments.")
        usage()
        exit(1)
      end
      beeTSPTest(
        other_funcs,
        parse(Int, args[7]),
        [
          bees_count,
          stopCriterion,
          stopCritAmount,
          visits_limit
        ]
      )

    elseif (mode == "random")
      if (length(args) < 11)
        println("Please provide at least 15 arguments.")
        usage()
        exit(1)
      end
      if (args[11] == "euclidean")
        random = generateEuclidean
      elseif (args[11] == "asymmetric")
        random = generateAsymmetric
      else 
        println("Invalid random mode provided")
        usage()
        exit(1)
      end
      beeRandomTest(
        other_funcs,
        parse(Int, args[7]),
        parse(Int, args[8]),
        parse(Int, args[9]),
        parse(Int, args[10]),
        random,
        [
          bees_count,
          stopCriterion,
          stopCritAmount,
          visits_limit
        ]
      )

    else
      tsp = readTSP(args[1])
      dict_tsp = structToDict(tsp)
      time = @elapsed distance = produce_honey(
        dict_tsp[:weights],
        dict_tsp[:dimension],
        random_swarm(bees_count),
        nodeWeightSum,
        visits_limit,
        stopCriterion(stopCritAmount)
      )[2]

      println("Bees nectar: $(distance)")
      println("Honey production time: $(time)s")
    end
  catch e
    throw(e)
    println(e)
    exit(1)
  end

end 

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 