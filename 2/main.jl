include("./testing.jl")
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
   2: starting solution [krand, 2opt, nn, rnn]
   3: move type [swap, insert, invert]
   4: stop criterion [time, iteration]
   5: stop criterion limit [seconds, number of iterations]
   6: tabu size [uint]
   7: aspiration as percentage [0-100]
   8: backtrack size [uint]
   9: stagnation limit [uint]
   10: other funcs (comma separated) from: [krand, 2opt, nn, rnn] or "all"
   11: repeats (if mode == hardcoded or random) [uint]
   12: start number of nodes (if mode == random) [uint]
   13: step number of nodes (if mode == random) [uint]
   14: end number of nodes (if mode == random) [uint]
   15: random type [euclidean, assymetric]
   """)
end

"""
Main function that with certain arguments given, starts tabu search.
Args neeed specified in usage function
"""
function main(args::Array{String})
  startingAlgs = Dict("krand" => krandom, "2opt" => twoopt, "nn" => nearestNeighbour, "rnn" => repetitiveNearestNeighbour)
  moves = Dict("swap" => moveSwap, "insert" => moveInsert, "invert" => moveInvert)
  stopCriteria = Dict("time" => timeCriterion, "iteration" => iterationsCriterion)

  if (length(ARGS) < 9)
    println("Please provide at least 9 arguments.")
    usage()
    exit(1)
  end
  if (lowercase(args[1]) == "help")
    usage()
    exit(1)    
  end
  try
    mode = args[1]
    #tsp = openTSPFile()
    startingFunc = startingAlgs[args[2]]
    move = moves[args[3]]
    stopCriterion = stopCriteria[args[4]]
    stopCritAmount = parse(Int, args[5])
    tabuSize = args[6]
    aspiration = parse(Int, args[7])
    backtrackSize = args[8]
    stagnationLimit = parse(Int, args[9])
    other_funcs = Array{Function}([tabuSearch, values(startingAlgs)...])
    if (length(args) >= 10 && args[10] != "all")
      other_funcs = Array{Function}([tabuSearch])
      funcs = split(args[10], ",")
      for func in funcs
        if (haskey(startingAlgs, func))
          push!(other_funcs, startingAlgs[func])
        end
      end
    end

    if (mode == "hardcoded")
      if (length(args) < 11)
        println("Please provide at least 11 arguments.")
        usage()
        exit(1)
      end
      tabuTSPTest(
        other_funcs,
        parse(Int, args[11]),
        [
          move,
          stopCriterion,
          stopCritAmount,
          tabuSize,        #fld(dict_tsp[:dimension], 2),# 7,# trunc(Int, 2 * dict_tsp[:dimension] /  (1 + sqrt(5))),
          0.01 * aspiration,
          backtrackSize,
          stagnationLimit
        ]
      )
    elseif (mode == "random")
      if (length(args) < 15)
        println("Please provide at least 15 arguments.")
        usage()
        exit(1)
      end
      if (args[15] == "euclidean")
        random = generateEuclidean
      elseif (args[15] == "assymetric")
        random = generateAsymmetric
      else
        println("Invalid random mode provided.")
        usage()
        exit(1)
      end
      tabuRandomTest(
        other_funcs,
        parse(Int, args[11]),
        parse(Int, args[12]),
        parse(Int, args[13]),
        parse(Int, args[14]),
        random,
        [
          move,
          stopCriterion,
          stopCritAmount,
          tabuSize,        #fld(dict_tsp[:dimension], 2),# 7,# trunc(Int, 2 * dict_tsp[:dimension] /  (1 + sqrt(5))),
          0.01 * aspiration,
          backtrackSize,
          stagnationLimit
        ]
      )
    else
      tsp = readTSP(args[1])
      dict_tsp = structToDict(tsp)
      initial_path = startingFunc(dict_tsp)
      println("Tabu search distance: $(tabuSearch(
        initial_path,
        dict_tsp[:dimension],
        dict_tsp[:weights],
        move,
        stopCriterion(stopCritAmount), # timeCriterion(10),
        tabuSize,        #fld(dict_tsp[:dimension], 2),# 7,# trunc(Int, 2 * dict_tsp[:dimension] /  (1 + sqrt(5))),
        0.01 * aspiration,
        backtrackSize,
        stagnationLimit
        )[2]
      )")
      println("Two opt distance: $(nodeWeightSum(initial_path, dict_tsp[:weights]))")
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