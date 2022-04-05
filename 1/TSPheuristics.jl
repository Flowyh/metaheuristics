module TSPheuristics
  export krandom, twoopt, nearestNeighbour, repetitiveNearestNeighbour
  export openTSPFile, structToDict, BasicTSPTest, algorithmsTest, randomGraphsTest
  export nodeWeightSum, readTSP
  export generateEuclidean, generateAsymmetric
  export algsStrToFunc
  include("algorithms.jl")
  include("testing.jl")
  include("generate.jl")
end
