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
   6: swarm generator function ["swap", "insert", "invert", "rand", "x,y,z" where x = swap, y = invert and z = insert number of percentages (sum up to 100)]
   7: other funcs
   8: repeats (if mode == hardcoded or random) [uint]
   9: start number of nodes (if mode == random) [uint]
   10: step number of nodes (if mode == random) [uint]
   11: end number of nodes (if mode == random) [uint]
   12: random type [euclidean, assymetric]
   """)
end

"""
Main function that with certain arguments given, starts tabu search.
Args needed specified in usage function
"""
function main(args::Array{String})
  stopCriteria = Dict("time" => timeCriterion, "iteration" => iterationsCriterion)
  otherAlgs = Dict("krand" => krandom, "2opt" => twoopt, "nn" => nearestNeighbour, "rnn" => repetitiveNearestNeighbour, "tabu" => tabuSearch)
  swarms = Dict("swap" => swap_swarm, "invert" => invert_swarm, "insert" => insert_swarm, "rand" => random_swarm)

  if (length(ARGS) < 6)
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
    splitPercent = 0
    invertPercent = 0
    insertPercent = 0
    if (occursin(",", args[6]))
      numbers = split(args[6], ",")
      splitPercent = parse(Int, numbers[1])
      invertPercent = parse(Int, numbers[2])
      insertPercent = parse(Int, numbers[3])
      swarm_generator = prepared_swarm
    else
      swarm_generator = swarms[args[6]]
    end
    other_funcs = Array{Function}([produce_honey, collect(values(otherAlgs))...])
    if (length(args) >= 7 && args[7] != "all")
      other_funcs = Array{Function}([produce_honey])
      funcs = split(args[7], ",")
      for func in funcs
        if (haskey(otherAlgs, func))
          push!(other_funcs, otherAlgs[func])
        end
      end
    end

    if (mode == "hardcoded")
      if (length(args) < 8)
        println("Please provide at least 8 arguments.")
        usage()
        exit(1)
      end
      beeTSPTest(
        other_funcs,
        parse(Int, args[8]),
        [
          bees_count,
          stopCriterion,
          stopCritAmount,
          visits_limit,
          swarm_generator,
          splitPercent,
          invertPercent,
          insertPercent
        ]
      )

    elseif (mode == "random")
      if (length(args) < 12)
        println("Please provide at least 12 arguments.")
        usage()
        exit(1)
      end
      if (args[12] == "euclidean")
        random = generateEuclidean
      elseif (args[12] == "asymmetric")
        random = generateAsymmetric
      else 
        println("Invalid random mode provided")
        usage()
        exit(1)
      end
      beeRandomTest(
        other_funcs,
        parse(Int, args[8]),
        parse(Int, args[9]),
        parse(Int, args[10]),
        parse(Int, args[11]),
        random,
        [
          bees_count,
          stopCriterion,
          stopCritAmount,
          visits_limit,
          swarm_generator,
          splitPercent,
          invertPercent,
          insertPercent
        ]
      )

    else
      tsp = readTSP(args[1])
      dict_tsp = structToDict(tsp)
      time = @elapsed distance = produce_honey(
        dict_tsp[:weights],
        dict_tsp[:dimension],
        swarm_generator(bees_count, splitPercent, invertPercent, insertPercent),
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