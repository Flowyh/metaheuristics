using Plots
import UnicodePlots 
using TSPLIB
using TimesDates, Dates
using JSON

ENV["GKSwstype"] = "100"


"""
    structToDict(s) -> Dict

Converts struct object to Dict.

Ref: https://stackoverflow.com/a/70317636.

## Params:
- `s::Struct`: struct obj to convert to dict.

## Returns:
- `Dict`: struct converted to dict.

"""
function structToDict(s)
  return Dict(key => getfield(s, key) for key in propertynames(s))
end

"""
    openTSPFile()

Asks for `TSP` data direcory path and filename.

Opens the file and returns a struct type generated by TSPLIB.

## Returns:
- `TSP`: struct read from file from path.

"""
function openTSPFile()
  println("Hello! Please provide full path to your data folder: ")
  path = chomp(readline())
  for (root, dirs, files) in walkdir(path)
    options = files
  end
  filter!(s->occursin(r".tsp", s), options)
  for el in options
    for i in 1:4 print(el, "   ") end
    println()
  end
  println()
  println("Choose a file by writing a full file name:  ")
  response = chomp(readline())
  return readTSP(path * "/" * response)
end

"""
    getPathCoordsVector(path, coords) -> (Array{Float64}, Array{Float64})

Create a tuple of X and Y coords arrays in given path order.

## Params:
- `path::Vector{T<:Integer}`: visited nodes in a given path.
- `coords::AbstractMatrix{Float64}`: nodes' coordinates.

## Returns:
- Two element tuple of X/Y coords arrays. 

"""
function getPathCoordsVector(path::Vector{T}, coords::AbstractMatrix{Float64}) where T<:Integer
  x = Vector{Integer}();
  y = Vector{Integer}();
  for node in path
    node_coords = coords[node, :]
    append!(x, node_coords[1])
    append!(y, node_coords[2])
  end
  append!(x, coords[path[1], 1])
  append!(y, coords[path[1], 2])
  return (x, y)
end

"""
    BasicTSPTest(tsp_data, test_func, tests_num, saveplot=true)

Runs `test_num` tests on given TSP problem dataset.

Requires `test_func` function to compute path for current dataset.

Plots best path to the console.

## Params:
- `tsp_data::Dict`: `TSP` data.
- `test_func::{Function}`: function used to calculate a path for current TSP nodes.
- `tests_num::{Int}`: number of performed tests.
- `saveplot::{Bool}`: should the best path be plotted into console

"""
function BasicTSPTest(tsp_data::Dict, test_func::Function, objective::Function, tests_num::Int, saveplot=true, args...)
  best_path=[]
  best_distance=typemax(Float64)
  for i in 1:tests_num
    println("\n\n======================TEST $i=====================")
    computed_path = test_func(tsp_data, args...)
    # Test info:
    println("Dataset name: ", tsp_data[:name])
    println("Nodes: ", tsp_data[:dimension])
    println("Path: ", computed_path)
    curr_distance = objective(computed_path, tsp_data[:weights])
    println("Distance: ", curr_distance)
    diff = curr_distance - best_distance
    println("Diff: ", (diff >= 0 ? "+$diff" : "$diff"))
    if (curr_distance < best_distance) 
      best_distance = curr_distance
      best_path = computed_path
    end
    println("==================END OF TEST $i==================")
  end

  println("\n\n=======================BEST=======================")
  println("Path: ", best_path)
  println("Distance: ", best_distance)
  println("Plot:")
  coords = getPathCoordsVector(best_path, tsp_data[:nodes])
  plt = UnicodePlots.lineplot(coords[1], coords[2]; title="Current path", height=20, width=40)
  UnicodePlots.scatterplot!(plt, coords[1], coords[2]; marker=repeat(["X"], length(best_path)))
  println(plt)
  println("===================END OF TESTS===================\n")

  if (!saveplot) return end
  now = Dates.now()
  println("Saving plot to: ./plots/$now.png\n")
  plt = plot(coords[1], coords[2]; title="Current path", markershape=:circle, margin=10Plots.mm)
  isdir("./plots") || mkdir("./plots")
  savefig(plt, "./plots/$now.png")
end

function prd(dist, optimal)
  return (dist - optimal) / optimal * 100.0
end

function hardcodedData()
  return Dict(
    "bayg29.tsp" => 1610,
    "a280.tsp" => 2579,
    "ch130.tsp" => 6100,
    "brg180.tsp" => 1950,
    "lin105.tsp" => 14379,
    "pr76.tsp" => 108159,
    "ulysses16.tsp" => 6859,
    "tsp225.tsp" => 3916,
    "rd100.tsp" => 7910,
    "gr202.tsp" => 40160,
    "eil76.tsp" => 538,
    "ch150.tsp" => 6528,
    "berlin52.tsp" => 7542,
    "att48.tsp" => 10628,
    "eil51.tsp" => 426,
    "fri26.tsp" => 937,
    "gr96.tsp" => 55209,
    "st70.tsp" => 675,
    "burma14.tsp" => 3323,
    "hk48.tsp" => 11461,
    "bays29.tsp" => 2020,
    "brazil58.tsp" => 25395,
    "dantzig42.tsp" => 699,
    "rat99.tsp" => 1211
  )
end

function algorithmsTest(functions::Array{Function}, k, random=false)
  results = Dict()
  problems = hardcodedData()

  for func in functions
    results[func] = Dict()
  end
  
  for key in keys(results)
    results[key] = Dict("time" => Dict(), "prd" => Dict(), "best" => Dict())
  end

  reg = r"([0-9]+)"
  for problem in collect(keys(problems))
    println("PROBLEM: $problem")
    n = match(reg, problem)[1]
    tsp_data = structToDict(readTSP("./data/all/$problem"))
    for func in functions
      results[func]["time"][n] = []
      results[func]["best"][n] = []
      results[func]["prd"][n] = []
      best_path = krandom(tsp_data, 1)
      best_dist = nodeWeightSum(best_path, tsp_data[:weights])
      for i in 1:k
        test_start = time_ns()
        if (func == twoopt) path = func(tsp_data, best_path)
        elseif (func == krandom) path = func(tsp_data, k)
        else path = func(tsp_data, 1) end
        test_end = time_ns()
        push!(results[func]["time"][n], (test_end - test_start) * 1e-6)
        dist = nodeWeightSum(path, tsp_data[:weights])
        if (dist < best_dist)
          best_dist = dist
          best_path = path
        end
      end
      push!(results[func]["best"][n], best_dist)
      push!(results[func]["prd"][n], prd(best_dist, problems[problem]))
    end
  end

  now = Dates.now()
  isdir("./jsons") || mkdir("./jsons")
  for func in functions
    open("./jsons/$(func)-k$k-$now.json", "w") do io
      JSON.print(io, results[func])
    end;
  end
end

function randomGraphsTest(functions::Array{Function}, k, start, step, s_end, random)
  results = Dict()

  for func in functions
    results[func] = Dict()
  end
  for key in keys(results)
    results[key] = Dict("time" => Dict(), "prd" => Dict(), "best" => Dict())
  end
  reg = r"([0-9]+)"
  for n in start:step:s_end
    println("PROBLEM: $n")
    (nodes, distances) = random(n, 5n)
    tsp_data = Dict(:dimension => n, :weights => distances)
    best_func = typemax(Int)
    best_dist_funcs = Dict()
    for func in functions
      results[func]["time"][n] = []
      results[func]["best"][n] = []
      results[func]["prd"][n] = []
      best_path = krandom(tsp_data, 1)
      best_dist = nodeWeightSum(best_path, tsp_data[:weights])
      for i in 1:k
        test_start = time_ns()
        if (func == twoopt) path = func(tsp_data, best_path)
        elseif (func == krandom) path = func(tsp_data, k)
        else path = func(tsp_data, 1) end
        test_end = time_ns()
        push!(results[func]["time"][n], (test_end - test_start) * 1e-6)
        dist = nodeWeightSum(path, tsp_data[:weights])
        if (dist < best_dist)
          best_dist = dist
          best_path = path
        end
      end
      best_dist_funcs[func] = best_dist
      best_func = (best_func > best_dist ? best_dist : best_func)
      push!(results[func]["best"][n], best_dist)
    end
    for func in functions
      push!(results[func]["prd"][n], prd(best_dist_funcs[func], best_func))
    end
  end

  now = Dates.now()
  isdir("./jsons") || mkdir("./jsons")
  for func in functions
    open("./jsons/$(func)_RANDOMS-k$k-b$start-s$step-e$s_end-$now.json", "w") do io
      JSON.print(io, results[func])
    end;
  end
end