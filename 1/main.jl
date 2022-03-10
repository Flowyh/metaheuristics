using TSPLIB
using Random

#=
Convert struct to dictionary https://stackoverflow.com/a/70317636
Params:
  @s Struct type
Returns:
  Dictionary of struct object's fields and values
=#
function struct_to_dict(s)
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
function obj_function(path::Vector{T}, weights::AbstractMatrix{Float64}) where T<:Integer
  @assert isperm(path) "Invalid path provided"
  result = length(path) != size(weights, 1) ? zero(Float64) : weights[path[end], path[1]]
  for i = 1:length(path)-1
    result += weights[path[i], path[i + 1]]
  end
  return result
end

#=
Main program function
=#
function main()
  # TODO: Make CLI for choosing specific dataset from all TSPLIB sets
  # Remove this:
  tsp = readTSP("./data/all/a280.tsp")
  dict_tsp = struct_to_dict(tsp)
  test = shuffle(collect(1:dict_tsp[:dimension])) # Random permutation of nodes
  println("Dataset name: ", dict_tsp[:name])
  println("Path: ", test)
  println("Distance: ", obj_function(test, dict_tsp[:weights])) # Print obj function
end

main()