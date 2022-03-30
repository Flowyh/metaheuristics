include("TSPheuristics.jl")
using .TSPheuristics

"""
Main program function
"""
function main(args::Array{String})
  if (length(ARGS) >= 1) tsp = readTSP(ARGS[1])
  else tsp = openTSPFile() end

  saveplot = true
  if (length(ARGS) >= 2)
    saveplot = ARGS[2] == "no" ? false : true
  end

  dict_tsp = structToDict(tsp)
  BasicTSPTest(dict_tsp, twoopt, nodeWeightSum, 1, saveplot)
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 