include("./artificial_bee_colony.jl")
using .ArtificialBeeColony
include("../1/generate.jl")

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
   6: repeats (if mode == hardcoded or random) [uint]
   7: start number of nodes (if mode == random) [uint]
   8: step number of nodes (if mode == random) [uint]
   9: end number of nodes (if mode == random) [uint]
   10: random type [euclidean, assymetric]
   """)
end

"""
Main function that with certain arguments given, starts tabu search.
Args needed specified in usage function
"""
function main(args::Array{String})
  stopCriteria = Dict("time" => timeCriterion, "iteration" => iterationsCriterion)

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
  catch e
    throw(e)
    println(e)
    exit(1)
  end

end 

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 