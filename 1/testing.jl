using Plots
import UnicodePlots 
using Dates

ENV["GKSwstype"] = "100"

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