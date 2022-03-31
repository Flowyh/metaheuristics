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

function plot_data(ns::Vector{Int}, data, step::Int, s_end::Int, algs, xl::String, yl::String, t::String, w=800, h=1200)
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

function plot_avgs(ns::Vector{Int}, data, step::Int, s_end::Int, alg, xl::String, yl::String, t::String, skip::Bool, option::Int)
  keys = sort_keys(data)
  avgs = Vector{Float64}()

  for key in keys
    push!(avgs, avg_vector(data[key]))
  end
  if option == 1
    if (!skip) plt = plot_data(ns, avgs, step, s_end, alg, xl, yl, t) end
  elseif option == 2
  l = @layout [a ; b ; c]
  p1 = plot_data(ns, avgs, step, s_end, alg, xl, yl, t)
  avgs_n = map((x,y) -> (x / y), avgs, ns)
  p2 = plot_data(ns, avgs_n, step, s_end, alg, "$xl test" ,"$yl / n", "$t / n")
  avgs_nlogn = map((x,y) -> (x*10 / y / y), avgs, ns)
  p3 = plot_data(ns, avgs_nlogn, step, s_end, alg, xl, "$yl * 1000 / n^2", "$t *1000 / n^2")
   
  plt = plot(p1,p2,p3, layout = l)
  end
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
  ns1 = []
  ns2 = []
  for key in keys(data)
    println("CURRENT: $key k$k")
    isdir("./plots/$key") || mkdir("./plots/$key")
    push!(algs, key)
    plot_path = "./plots/$key/$key-k$k"

    #skip = isfile("$plot_path-time-avg.png") ? true : false
    ns = str_to_int_vector(sort_keys(data[key]["time"]))
    ns1 = str_to_int_vector(sort_keys(data[key]["prd"]))
    ns2 = str_to_int_vector(sort_keys(data[key]["best"]))
    (plt_time, avg_time) = plot_avgs(ns, data[key]["time"], step, s_end, string(key), "Number of nodes", "Average time [ms]", "$key average time [k=$k]", false, 1)
    (plt_prd, prd) = plot_avgs(ns1, data[key]["prd"], step, s_end, string(key), "Number of nodes", "PRD", "$key PRD [k=$k]", false, 1)
    (plt_best, best) = plot_avgs(ns2, data[key]["best"], step, s_end, string(key), "Number of nodes", "PRD", "$key best path [k=$k]", false, 1)
    (plt_complex, avg_time) = plot_avgs(ns, data[key]["time"], step, s_end, string(key), "Number of nodes", "Average time [ms]", "$key average time [k=$k]", false, 2)
    savefig(plt_time, "$plot_path-time-avg.png")
    savefig(plt_prd, "$plot_path-prd-avg.png")
    savefig(plt_best, "$plot_path-best-path.png")
    savefig(plt_complex, "$plot_path-complex.png")
    push!(avg_times, avg_time)
    push!(avg_prd, prd)
    push!(avg_best_path, best)
  end
  if (length(algs) == 1) return end
  plt_avg_time = plot_data(ns, avg_times, step, s_end, permutedims(algs), "Number of nodes", "Average time [ms]", "Average time for algs [k=$k]", 800, 600)
  plt_avg_prd = plot_data(ns1, avg_prd, step, s_end, permutedims(algs), "Number of nodes", "PRD", "PRD for algs [k=$k]", 800, 600)
  plt_avg_path = plot_data(ns2, avg_best_path, step, s_end, permutedims(algs), "Number of nodes", "Best path", "Best path for algs [k=$k]", 800, 600)
  algs_prefix = join(algs, "_")
  isdir("./plots/$algs_prefix") || mkdir("./plots/$algs_prefix")
  savefig(plt_avg_time, "./plots/$algs_prefix/$algs_prefix-k$k-time-avgs.png")
  savefig(plt_avg_prd, "./plots/$algs_prefix/$algs_prefix-k$k-prd-avgs.png")
  savefig(plt_avg_path, "./plots/$algs_prefix/$algs_prefix-k$k-best-path-avgs.png")
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
    throw(e)
    exit(1)
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end