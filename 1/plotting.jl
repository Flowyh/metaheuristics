using Plots
using LaTeXStrings
import JSON

ENV["GKSwstype"] = "100"

alg_names = Dict(
  "twoopt" => "2opt",
  "nearestNeighbour" => "nn",
  "repetitiveNearestNeighbour" => "rnn",
  "krandom" => "krand",
)

function str_to_int_vector(a::Array{String})
  return map(x -> parse(Int, x), a)
end

function lexicographic_cmp(x::String)
   number_idx = findfirst(isdigit, x)
   str, num = SubString(x, 1, number_idx-1), SubString(x, number_idx, length(x))
   return str, parse(Int, num)
end

function sort_keys(dict::Dict)
  return sort(collect(keys(dict)), by=lexicographic_cmp)
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

function avg_vector(V::Vector{Any})
  V_len = length(V)
  sum = reduce(+, V)
  return sum / V_len
end

function plot_data(ns::Vector{Int}, data, step::Int, s_end::Int, algs, xl::String, yl::String, t::String, w=800, h=600)
  plt = plot(ns, data, 
    xticks = 0:step:s_end,
    xlabel = xl,  
    ylabel = yl,
    yformatter = :plain,
    labels = algs,
    title = t,
    margin = 10Plots.mm,
    marker = (:circle, 5),
    legend = :right
    )
  plot!(plt, size=(w, h))
  return plt
end

function plot_avgs(ns::Vector{Int}, data, step::Int, s_end::Int, sort, xl::String, yl::String, t::String, skip::Bool)
  keys = sort_keys(data)
  avgs = Vector{Float64}()

  for key in keys
    push!(avgs, avg_vector(data[key]))
  end
  if (!skip) plt = plot_data(ns, avgs, step, s_end, sort, xl, yl, t) end
  return (plt, avgs)
end

function plots(step::Int, s_end::Int, k::Int, algs::Array{String})
  isdir("./plots") || mkdir("./plots")
  data = read_files(algs, k)
  avg_prd = Vector{Vector{Float64}}()
  avg_best_path = Vector{Vector{Float64}}()
  avg_times = Vector{Vector{Float64}}()
  algs = []
  ns = []
  for key in keys(data)
    println("CURRENT: $key k$k")
    isdir("./plots/$key") || mkdir("./plots/$key")
    push!(algs, key)
    plot_path = "./plots/$key/$key-k$k"

    skip = isfile("$plot_path-time-avg.png") ? true : false
    ns = str_to_int_vector(sort_keys(data[key]["time"]))
    (plt_time, avg_time) = plot_avgs(ns, data[key]["time"], step, s_end, string(key), "Number of nodes", "Average time [ms]", "$key average time [k=$k]", false)
    savefig(plt_time, "$plot_path-time-avg.png")
    push!(avg_times, avg_time)
  end
  if (length(algs) == 1) return end
  plt_avg_time = plot_data(ns, avg_times, step, s_end, permutedims(algs), "Number of nodes", "Average time [ms]", "Average time for algs [k=$k]", 800, 600)
  algs_prefix = join(algs, "_")
  isdir("./plots/$algs_prefix") || mkdir("./plots/$algs_prefix")
  savefig(plt_avg_time, "./plots/$algs_prefix/$algs_prefix-k$k-time-avgs.png")
end

function usage()
  println("Usage: julia plotting.jl [step] [end] [k] [algorithms(defualt=all), split by space]")
end

function main(args::Array{String})
  if (length(args) < 3)
    println("Please provide at least 3 arguments.")
    usage()
    exit(1)
  end
  try
    step = parse(Int, args[1])
    s_end = parse(Int, args[2])
    k = parse(Int, args[3])
    algs = ["2opt", "nn", "rnn", "krand"]
    if (length(args) == 4)
      algs::Vector{String} = split(strip(args[4]))
      println(algs)
    end
    if !issubset(algs, ["2opt", "nn", "rnn", "krand"])
      println("Invalid algorithm type provided")
      println("Options: 2opt, nn, rnn, krand")
      exit(1)
    end 
    plots(step, s_end, k, algs)
  catch e
    println("Error")
    exit(1)
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end