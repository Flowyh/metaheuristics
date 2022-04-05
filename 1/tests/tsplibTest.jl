include("../TSPheuristics.jl")
using .TSPheuristics

"""
Main program function
"""
function main(args::Array{String})
  if (length(ARGS) >= 1) tsp = readTSP(ARGS[1])
  else tsp = openTSPFile() end

  if (length(ARGS) >= 2)
    if (ARGS[2] == "krand") alg = krandom
    elseif (ARGS[2] == "nn") alg = nearestNeighbour
    elseif (ARGS[2] == "rnn") alg = repetitiveNearestNeighbour
    elseif (ARGS[2] == "2opt") alg = twoopt end
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