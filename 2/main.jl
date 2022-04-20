include("./tabuSearch.jl")
using .TabuSearch
using TSPLIB

function main(args::Array{String})
  if (length(ARGS) >= 1) tsp = readTSP(ARGS[1])
  else tsp = openTSPFile() end

  dict_tsp = structToDict(tsp)
  initial_path = nearestNeighbour(dict_tsp)
  
  println(tabuSearch(
      initial_path,
      dict_tsp[:dimension],
      dict_tsp[:weights],
      move_swap, 
      function() end, 
      10
    )
  )
  println(nodeWeightSum(initial_path, dict_tsp[:weights]))
end 

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 