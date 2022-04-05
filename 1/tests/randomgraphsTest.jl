include("../TSPheuristics.jl")
using .TSPheuristics

"""
Program usage info.
"""
function usage()
  println("Usage: julia randomgraphsTest.jl [k] [start] [step] [s_end] [algorithms(defualt=all), split by space]")
end

"""
Test heuristics on random graphs.

Test logic: testing.jl -> randomGraphsTest()

## Params (inferred from cmd line arguments)

- `args[1]` : k number of tests
- `args[2]` : start number of nodes
- `args[3]` : step between each number of nodes
- `args[4]` : end number of nodes
- `args[5]` : list of tested heuristics

"""
function main(args::Array{String})
  if (length(args) < 4)
    println("Please provide at least 4 argument.")
    usage()
    exit(1)
  end
  try
    k = parse(Int, args[1])
    start = parse(Int, args[2])
    step = parse(Int, args[3])
    s_end = parse(Int, args[4])
    algs = ["2opt", "nn", "rnn", "krand"]
    if (length(args) == 5)
      algs::Vector{String} = split(strip(args[5]))
      println(algs)
    end
    if !issubset(algs, ["2opt", "nn", "rnn", "krand"])
      println("Invalid algorithm type provided")
      println("Options: 2opt, nn, rnn, krand")
      exit(1)
    end 
    randomGraphsTest(algsStrToFunc(algs), k, start, step, s_end, generateAsymmetric)
  catch e
    throw(e)
    println("Error")
    exit(1)
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 