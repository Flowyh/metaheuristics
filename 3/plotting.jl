using Plots
using LaTeXStrings
import JSON

ENV["GKSwstype"] = "100"

const alg_names = Dict(
  "twoopt" => "2opt",
  "nearestNeighbour" => "nn",
  "repetitiveNearestNeighbour" => "rnn",
  "krandom" => "krand",
  "tabuSearch" => "tabu",
  "artificialBeeColony"  => "abc",
)

const modes = Dict(
  "swarm" => "Swarm type to generate function comparison for Artificial Bee Colony",
  "beesCount" => "Bees count value comparison for Artificial Bee Colony",
  "visitsLimit" => "Visits limit comparison for Artificial Bee Colony",
  "selection" => "Selection algorithm comparison for Artificial Bee Colony",
  "stop" => "Stop criterion limit comparison for Artificial Bee Colony",
  "threads" =>  "Number of threads comparison for Artificial Bee Colony"
)

function beesParameter(f_split, mode::String)
  if (mode == "swarm")
    return f_split[7]
  elseif (mode == "beesCount")
    return f_split[3]
  elseif (mode == "visitsLimit")
    return f_split[6]
  elseif (mode == "selection")
    return "$(f_split[8])_$(f_split[9])"
  elseif (mode == "stop")
    return f_split[4]
  elseif (mode == "threads")
    return f_split[10]
  else
    return ""
  end
end

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

function read_files(algs::Array{String}, k::Int, date::String, mode::String)
  !isdir("./jsons") && return
  data = Dict()
  foreach(readdir("./jsons")) do f
    f_split = split(strip(f), "-")
    currentFileDate = join([f_split[end-2],f_split[end-1],f_split[end]], "-")
    currentFileDate = strip(currentFileDate, ['.','j','s','o','n'])
    if (occursin(date, currentFileDate) && alg_names[f_split[1]] in algs)
      name = f_split[1]
      if (name == "artificialBeeColony" && mode != "none") name *= "-$(beesParameter(f_split, mode))" end
      data[name] = JSON.parsefile("./jsons/$f"; dicttype=Dict, inttype=Int, use_mmap=true)    
    end
  end
  println(keys(data))
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

function plot_avgs(ns::Vector{Int}, data, step::Int, s_end::Int, k::Int, alg, xl::String, yl::String, t::String, skip::Bool, option::Int)
  keys = sort_keys(data)
  avgs = Vector{Float64}()

  for key in keys
    push!(avgs, avg_vector(data[key]))
  end
  if option == 1
    if (!skip) plt = plot_data(ns, avgs, step, s_end, alg, xl, yl, t, 800, 600) end
  elseif option == 2
    l = @layout [a ; b ; c ; d]
    p1 = plot_data(ns, avgs, step, s_end, alg, xl, yl, t)
    if (alg == "krandom") 
      scale = [k + i for i in ns] 
      scale_n = "k+n"
    else scale = ns
      scale_n = "n" end
    avgs_n = map((x,y) -> (1000x / y), avgs, scale)
    p2 = plot_data(ns, avgs_n, step, s_end, alg, "$xl test" ,"$yl / $scale_n", "$t / $scale_n")
    avgs_n2 = map((x,y) -> (1000x / (y^2)), avgs, scale)
    p3 = plot_data(ns, avgs_n2, step, s_end, alg, xl, "$yl / ($scale_n)^2", "$t / $scale_n^2")
    avgs_n3 = map((x,y) -> (1000x / (y^3)), avgs, scale)
    p4 = plot_data(ns, avgs_n3, step, s_end, alg, xl, "$yl / ($scale_n)^3", "$t / $scale_n^3")
    
    plt = plot(p1, p2, p3, p4, layout = l)
  end
  return (plt, avgs)
end

function plots(step::Int, s_end::Int, k::Int, algs::Array{String}, date::String, mode::String)
  isdir("./plots") || mkdir("./plots")
  data = read_files(algs, k, date, mode)
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
    ns = str_to_int_vector(sort_keys(data[key]["time"]))
    ns1 = str_to_int_vector(sort_keys(data[key]["prd"]))
    ns2 = str_to_int_vector(sort_keys(data[key]["best"]))
    (plt_time, avg_time) = plot_avgs(ns, data[key]["time"], step, s_end, k, string(key), "Number of nodes", "Average time [ms]", "$key average time [k=$k]", false, 1)
    if (!isfile("$plot_path-prd-avg.png"))
      (plt_prd, prd) = plot_avgs(ns1, data[key]["prd"], step, s_end, k, string(key), "Number of nodes", "PRD", "$key PRD [k=$k]", false, 1)
      savefig(plt_prd, "$plot_path-prd-avg.png")
      push!(avg_prd, prd)
    end
    (plt_best, best) = plot_avgs(ns2, data[key]["best"], step, s_end, k, string(key), "Number of nodes", "Best distance", "$key best path [k=$k]", false, 1)
    # (plt_complex, avg_time) = plot_avgs(ns, data[key]["time"], step, s_end, k, string(key), "Number of nodes", "Average time [s]", "$key average time [k=$k]", false, 2)
    savefig(plt_time, "$plot_path-time-avg.png")
    savefig(plt_best, "$plot_path-best-path.png")
    # savefig(plt_complex, "$plot_path-complex.png")
    push!(avg_times, avg_time)
    push!(avg_best_path, best)
  end
  if (length(algs) == 1) return end
  algs_prefix = "all"
  isdir("./plots/$algs_prefix") || mkdir("./plots/$algs_prefix")
  if (length(avg_prd) > 0) 
    plt_avg_prd = plot_data(ns1, avg_prd, step, s_end, permutedims(algs), "Number of nodes", "PRD", "PRD for algs [k=$k]", 800, 600)
    savefig(plt_avg_prd, "./plots/$algs_prefix/$algs_prefix-k$k-prd-avgs.png")
  end
  plt_avg_path = plot_data(ns2, avg_best_path, step, s_end, permutedims(algs), "Number of nodes", "Best path", "Best path for algs [k=$k]", 800, 600)
  plt_avg_time = plot_data(ns, avg_times, step, s_end, permutedims(algs), "Number of nodes", "Average time [ms]", "Average time for algs [k=$k]", 800, 600)
  savefig(plt_avg_time, "./plots/$algs_prefix/$algs_prefix-k$k-time-avgs.png")
  savefig(plt_avg_path, "./plots/$algs_prefix/$algs_prefix-k$k-best-path-avgs.png")
end

function usage()
  println("Usage: julia plotting.jl [step] [end] [k] [date] [algorithms(defualt=all), split by space] [mode(default=none)]")
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
    date = args[4]
    algs = collect(values(alg_names))
    if (length(args) >= 5)
      algs::Vector{String} = split(strip(args[5]))
      println(algs)
    end
    if !issubset(algs, values(alg_names))
      println("Invalid algorithm type provided")
      println("Options: 2opt, nn, rnn, krand, tabu, abc")
      exit(1)
    end
    mode = "none"
    if (length(args) >= 6)
      if (args[6] in keys(modes)) mode = args[6]
      else mode = "none" end
    end
    println(mode)
    plots(step, s_end, k, algs, date, mode)
  catch e
    println("Error")
    throw(e)
    exit(1)
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end