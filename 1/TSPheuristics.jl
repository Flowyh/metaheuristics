module TSPheuristics
  export krandom, twoopt, nearestNeighbour, repetitiveNearestNeighbour
  export openTSPFile, structToDict, BasicTSPTest, algorithmsTest, randomGraphsTest
  export nodeWeightSum
  export generateEuclidean, generateAsymmetric
  include("algorithms.jl")
  include("testing.jl")
  include("generate.jl")
end
