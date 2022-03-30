module TSPheuristics
  export krandom, twoopt, nearestNeighbour, repetitiveNearestNeighbour
  export openTSPFile, structToDict, BasicTSPTest, algorithmsTest
  export nodeWeightSum
  include("algorithms.jl")
  include("testing.jl")
end
