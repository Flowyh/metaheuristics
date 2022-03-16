using TSPLIB
using Random
using UnicodePlots

#=
Convert struct to dictionary https://stackoverflow.com/a/70317636
Params:
  @s Struct type
Returns:
  Dictionary of struct object's fields and values
=#
function structToDict(s)
  return Dict(key => getfield(s, key) for key in propertynames(s))
end

#=
Returns path's length
Params:
  @path: Vector{<:Integer} of visited nodes in a given path
  @weights: AbstractMatrix{Float64} of distances between nodes
Returns:
  Sum of distances between nodes in given path
=#
function objFunction(path::Vector{T}, weights::AbstractMatrix{Float64}) where T<:Integer
  @assert isperm(path) "Invalid path provided"
  result = length(path) != size(weights, 1) ? zero(Float64) : weights[path[end], path[1]]
  for i = 1:length(path)-1
    result += weights[path[i], path[i + 1]]
  end
  return result
end

#=
Create a tuple of X and Y coords arrays
Array of X coords = result[1]
Array of Y coords = result[1]
Params:
  @path: Vector{<:Integer} of visited nodes in a given path
  @coords: AbstractMatrix{Float64} of nodes coordinates
Returns:
  Two element tuple of X/Y coords arrays.
  E.g: (Integer[1,2,3], Integer[2,3,4])
=#
function getPathCoordsVector(path::Vector{T}, coords::AbstractMatrix{Float64}) where T<:Integer
  x = Vector{Integer}();
  y = Vector{Integer}();
  for node in path
    node_coords = coords[node, :]
    append!(x, node_coords[1])
    append!(y, node_coords[2])
  end
  return (x, y)
end

#=
Asks user for data direcory path and file name
Returns:
  A TSP struct read from file from path
=#
function openTSPFile()
  println("Hello! Please provide full path to your data folder: ")
  path = chomp(readline())
  for (root, dirs, files) in walkdir(path)
    global options = files
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

#=
Returns a random [1..n] permutation of given length
Params:
  @tsp_data: {Dict} TSP dataset
Returns:
  Permutation of TSP dataset nodes
=#
function randomPath(tsp_data::Dict)
  return shuffle(collect(1:tsp_data[:dimension]))
end

#=
Runs test_num tests on given tsp_data dictionary.
Requires test_func function to compute path for current dataset
Params:
  @tsp_data: {Dict} TSP dataset
  @test_func: {Function} function used to calculate a path for current TSP nodes
  @tests_num: number of performed tests
=#
function TSPtest(tsp_data::Dict, test_func::Function, tests_num::Int)
  for i in 1:tests_num
    println("\n\n================TEST $i================")
    computed_path = test_func(tsp_data)
    # Test info:
    println("Dataset name: ", tsp_data[:name])
    println("Nodes: ", tsp_data[:dimension])
    println("Path: ", computed_path)
    println("Distance: ", objFunction(computed_path, tsp_data[:weights]))
    # Plotting
    println("Plot:")
    coords = getPathCoordsVector(computed_path, tsp_data[:nodes])
    plt = lineplot(coords[1], coords[2]; title="Current path", height=20, width=40)
    println(plt)
    println("=============END OF TEST $i=============")
  end
end

#=
Main program function
=#
function main()
  tsp = openTSPFile()
  dict_tsp = structToDict(tsp)
  TSPtest(dict_tsp, randomPath, 10)
end

main()