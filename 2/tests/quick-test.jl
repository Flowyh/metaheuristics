include("../testing.jl")

funcs = Array{Function}([tabuSearch, krandom])

tabuTSPTest(funcs, 10, [moveInvert, iterationsCriterion, 1000, 7, 0.05, 15, 200])