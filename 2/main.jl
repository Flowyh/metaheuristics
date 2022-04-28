include("./tabuSearch.jl")
using .TabuSearch
using TSPLIB

function main(args::Array{String})
  if (length(ARGS) >= 1) tsp = readTSP(ARGS[1])
  else tsp = openTSPFile() end

  dict_tsp = structToDict(tsp)
  initial_path = twoopt(dict_tsp)
  
  println("Tabu search distance: $(tabuSearch(
      initial_path,
      dict_tsp[:dimension],
      dict_tsp[:weights],
      moveInvert,
      iterationsCriterion(100000), # timeCriterion(10),
      fld(dict_tsp[:dimension], 2),# 7,# trunc(Int, 2 * dict_tsp[:dimension] /  (1 + sqrt(5))),
      0.05,
      15,
      2000
    )[2]
  )")
  println("Two opt distance: $(nodeWeightSum(initial_path, dict_tsp[:weights]))")
end 

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 