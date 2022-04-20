include("./tabooSearch.jl")
using .TabooSearch
using TSPLIB

function main(args::Array{String})
  if (length(ARGS) >= 1) tsp = readTSP(ARGS[1])
  else tsp = openTSPFile() end

  dict_tsp = structToDict(tsp)
  initial_path = nearestNeighbour(dict_tsp)
  
  println("Taboo search distance: $(tabooSearch(
      initial_path,
      dict_tsp[:dimension],
      dict_tsp[:weights],
      move_invert, 
      timeCriterion(10), # iterationsCriterion(10000),
      15,
      addAspiration,
      0.0001,
      -0.01,
      1
    )[2]
  )")
  println("Two opt distance: $(nodeWeightSum(initial_path, dict_tsp[:weights]))")
end 

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 