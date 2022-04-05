include("../TSPheuristics.jl")
using .TSPheuristics

function usage()
  println("Usage: julia hardcodedTest.jl [k] [algorithms(defualt=all), split by space]")
end

"""
Main program function
"""
function main(args::Array{String})
  if (length(args) < 1)
    println("Please provide at least 1 argument.")
    usage()
    exit(1)
  end
  try
    k = parse(Int, args[1])
    algs = ["2opt", "nn", "rnn", "krand"]
    if (length(args) == 2)
      algs::Vector{String} = split(strip(args[2]))
      println(algs)
    end
    if !issubset(algs, ["2opt", "nn", "rnn", "krand"])
      println("Invalid algorithm type provided")
      println("Options: 2opt, nn, rnn, krand")
      exit(1)
    end 
    algorithmsTest(algsStrToFunc(algs), k)
  catch e
    throw(e)
    println("Error")
    exit(1)
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end 