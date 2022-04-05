using HypothesisTests
import JSON

alg_names = Dict(
  "twoopt" => "2opt",
  "nearestNeighbour" => "nn",
  "repetitiveNearestNeighbour" => "rnn",
  "krandom" => "krand",
)

function lexicographic_cmp(x::String)
   number_idx = findfirst(isdigit, x)
   str, num = SubString(x, 1, number_idx-1), SubString(x, number_idx, length(x))
   return str, parse(Int, num)
end

function read_files(algs::Array{String}, k::Int)
  !isdir("./jsons") && return
  data = Dict()
  foreach(readdir("./jsons")) do f
    f_split = split(strip(f), "-")
    if (alg_names[f_split[1]] in algs
      && "k$k" in f_split
    )
      data[f_split[1]] = JSON.parsefile("./jsons/$f"; dicttype=Dict, inttype=Int, use_mmap=true)
    end
  end
  return data
end

function sort_keys(dict::Dict)
  return sort(collect(keys(dict)), by=lexicographic_cmp)
end

function main(args::Array{String})
  if (length(args) < 1)
    println("Please provide at least 1 arguments.")
    usage()
    exit(1)
  end
  try
    k = parse(Int, args[1])
    algs = ["2opt", "nn", "rnn", "krand"]
    data = read_files(algs, k)
    if (data === Nothing) return end

    two_opt_prds = Vector{Real}()
    rnn_prds = Vector{Real}()
    for k in sort_keys(data["twoopt"]["prd"])
      push!(two_opt_prds, Real(data["twoopt"]["prd"][k][1]))
    end
    
    for k in sort_keys(data["repetitiveNearestNeighbour"]["prd"])
      push!(rnn_prds, Real(data["repetitiveNearestNeighbour"]["prd"][k][1]))
    end
    println("Wilcoxon test for: Repetitive Nearest Neighbour and 2opt")
    println("H0: Distribution of (rnn prd - opt prd) has zero median")
    println(SignedRankTest(two_opt_prds, rnn_prds))
  catch e
    println("Error")
    throw(e)
    exit(1)
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end