include("../TSPheuristics.jl")
using .TSPheuristics

"""
Program usage info.
"""
function usage()
  println("Usage: julia tsplibTest.jl [tsplib data path] [algorithms(defualt=all), split by space] [save plot?(default=yes)]")
  println("")
end

"""
Test heuristics on given TSPLIB dataset.

Test logic: testing.jl -> BasicTSPTest()

## Params (inferred from cmd line arguments)

- `args[1]` : tsplib dataset path
- `args[2]` : heuristic name (options: krand/nn/rnn/2opt)
- `args[3]` : should we save plot after the test? (default=yes/no)

# If no command line arguments are provided, there's a prompt asking for directory path for TSPLIB files.

"""
function main(args::Array{String})
  if (length(ARGS) >= 1) tsp = readTSP(ARGS[1])
  else tsp = openTSPFile() end

  alg = twoopt
  if (length(ARGS) >= 2)
    if (ARGS[2] == "krand") alg = krandom
    elseif (ARGS[2] == "nn") alg = nearestNeighbour
    elseif (ARGS[2] == "rnn") alg = repetitiveNearestNeighbour
    elseif (ARGS[2] == "2opt") alg = twoopt
    else
      println("Invalid heursitic type provided.")
      usage()
    end
  end

  saveplot = true
  if (length(ARGS) >= 3)
    saveplot = ARGS[3] == "no" ? false : true
  end

  dict_tsp = structToDict(tsp)
  println("ALGORITHM: $alg")
  BasicTSPTest(dict_tsp, alg, nodeWeightSum, 1000, saveplot)
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 