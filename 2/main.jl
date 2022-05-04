include("./tabuSearch.jl")
using .TabuSearch
using TSPLIB

export timeCriterion, iterationsCriterion

function usage()
   println("""
   Usage: julia zad2.jl
   ARGS:
   1: path to TSP file
   2: starting solution [krand, 2opt, nb, nnb]
   3: move type [swap, insert, invert]
   4: stop criteria [time, iteration]
   5: tabu size [uint]
   6: aspiration in percent [0-100]
   7: backtrack size [uint]
   8: stagnation limit [uint]
   """)
end


function main(args::Array{String})
  startingAlgs = Dict("krand" => krandom, "2opt" => twoopt, "nb" => nearestNeighbour, "nnb" => repetitiveNearestNeighbour)
  moves = Dict("swap" => moveSwap, "insert" => moveInsert, "invert" => moveInvert)
  stopCriteria = Dict("time" => timeCriterion, "iteration" => iterationsCriterion)

  if (length(ARGS) < 8)
    println("Please provide 8 arguments.")
    usage()
    exit(1)
  end
  if (lowercase(args[1]) == "help")
    usage()
    exit(1)    
  end
  try
    
    tsp = readTSP(args[1])
    #tsp = openTSPFile()
    startingFunc = startingAlgs[args[2]]
    move = moves[args[3]]
    stopCriterion = stopCriteria[args[4]]
    stopCritAmount = parse(Int, args[5])
    tabuSize = parse(Int, args[6])
    aspiration = parse(Int, args[7])
    backtrackSize = parse(Int, args[8])
    stagnationLimit = parse(Int, args[9])

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

  catch e
    println(e)
    exit(1)
  end

end 

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 