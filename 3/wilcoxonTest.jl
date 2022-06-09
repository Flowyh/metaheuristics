using HypothesisTests
import JSON

alg_names = Dict(
  "twoopt" => "2opt",
  "nearestNeighbour" => "nn",
  "repetitiveNearestNeighbour" => "rnn",
  "krandom" => "krand",
  "tabuSearch" => "tabu",
  "artificialBeeColony" => "abc",
)

function lexicographic_cmp(x::String)
   number_idx = findfirst(isdigit, x)
   str, num = SubString(x, 1, number_idx-1), SubString(x, number_idx, length(x))
   return str, parse(Int, num)
end

function read_files(algs::Array{String}, date::String)
  !isdir("./jsons") && return
  data = Dict()
  foreach(readdir("./jsons")) do f
    f_split = split(strip(f), "-")
    currentFileDate = join([f_split[end-2],f_split[end-1],f_split[end]], "-")
    currentFileDate = strip(currentFileDate, ['.','j','s','o','n'])
    if (occursin(date, currentFileDate) && alg_names[f_split[1]] in algs)
      name = f_split[1]
      data[name] = JSON.parsefile("./jsons/$f"; dicttype=Dict, inttype=Int, use_mmap=true)    
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
    date = args[1]
    algs = ["tabu", "abc"]
    data = read_files(algs, date)
    if (data === Nothing) return end

    two_opt_prds = Vector{Real}()
    rnn_prds = Vector{Real}()
    for key in sort_keys(data["tabuSearch"]["prd"])
      push!(two_opt_prds, Real(data["tabuSearch"]["prd"][key][1]))
    end
    
    for key in sort_keys(data["artificialBeeColony"]["prd"])
      push!(rnn_prds, Real(data["artificialBeeColony"]["prd"][key][1]))
    end

    println("Wilcoxon test for: Tabu Search vs Artificial Bee Colony")
    println("H0: Distribution of (tabu prd - abc prd) has zero median")
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