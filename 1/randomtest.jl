include("TSPheuristics.jl")
using .TSPheuristics

"""
Main program function
"""
function main(args::Array{String})
  length = parse(Int, args[1])
  if (args[2] == "euc") random_graph = generateEuclidean(length, 5length)
  elseif (args[2] == "asym") random_graph = generateAsymmetric(length, 5length) end

  nodes = zeros(Int, length, 2)
  index = 1
  for node in random_graph[1]
    nodes[index, 1] = node[1]
    nodes[index, 2] = node[2]
    index += 1
  end

  dict_tsp = Dict(:dimension => length, :nodes => nodes, :weights => random_graph[2], :name => "Random")

  if (args[3] == "krand") alg = krandom
  elseif (args[3] == "nn") alg = nearestNeighbour
  elseif (args[3] == "rnn") alg = repetitiveNearestNeighbour
  elseif (args[3] == "2opt") alg = twoopt end

  saveplot = args[4] == "no" ? false : true

  BasicTSPTest(dict_tsp, alg, nodeWeightSum, 1, saveplot)
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 