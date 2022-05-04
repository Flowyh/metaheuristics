include("./tabuSearch.jl")
using .TabuSearch
using TSPLIB
using TimesDates, Dates
import JSON

function hardcodedData()
  return Dict(
    "bayg29.tsp" => 1610,
    # "a280.tsp" => 2579,
    # "ch130.tsp" => 6100,
    # "brg180.tsp" => 1950,
    # "lin105.tsp" => 14379,
    # "pr76.tsp" => 108159,
    # "ulysses16.tsp" => 6859,
    # "tsp225.tsp" => 3916,
    # "rd100.tsp" => 7910,
    # "gr202.tsp" => 40160,
    # "eil76.tsp" => 538,
    # "ch150.tsp" => 6528,
    # "berlin52.tsp" => 7542,
    # "att48.tsp" => 10628,
    # "eil51.tsp" => 426,
    # "fri26.tsp" => 937,
    # "gr96.tsp" => 55209,
    # "st70.tsp" => 675,
    # "burma14.tsp" => 3323,
    # "hk48.tsp" => 11461,
    # "bays29.tsp" => 2020,
    # "brazil58.tsp" => 25395,
    # "dantzig42.tsp" => 699,
    # "rat99.tsp" => 1211
  )
end

function prd(dist, optimal)
  return (dist - optimal) / optimal * 100.0
end

function testTabuSearch(path, nodes, weights, mv, stop, ts, at, bs, sl)
    test_start = time_ns()
    (_, best_dist) = tabuSearch(path, 
      nodes, 
      weights, 
      mv,
      stop,
      ts,
      at,
      bs,
      sl
    )
    test_end = time_ns()
    return ([], best_dist, (test_end - test_start) * 1e-6)
end

function tabuTSPTest(functions::Array{Function}, k::Int, tabu_params::Array{Any})
  results = Dict()
  problems = hardcodedData()

  for func in functions
    results[func] = Dict()
  end

  (mv, stopFun, limit, ts, at, bs, sl) = tabu_params
  stop = stopFun(limit)
  
  for key in keys(results)
    results[key] = Dict("time" => Dict(), "prd" => Dict(), "best" => Dict())
  end

  reg = r"([0-9]+)"
  for problem in collect(keys(problems))
    println("PROBLEM: $problem")
    n = match(reg, problem)[1]
    tsp_data = structToDict(readTSP("../data/all/$problem"))
    for func in functions
      results[func]["time"][n] = []
      results[func]["best"][n] = []
      results[func]["prd"][n] = []
      if (func == tabuSearch)
        path = twoopt(tsp_data)
        (_, best_dist, time) = testTabuSearch(path, tsp_data[:dimension], tsp_data[:weights], mv, stop, ts, at, bs, sl)
        push!(results[func]["time"][n], time)
      else
        best_path = krandom(tsp_data, 1)
        best_dist = nodeWeightSum(best_path, tsp_data[:weights])
        for i in 1:k
          test_start = time_ns()
          if (func == twoopt) path = func(tsp_data, best_path)
          elseif (func == krandom) path = func(tsp_data, k)
          else path = func(tsp_data, 1) end
          test_end = time_ns()
          time = (test_end - test_start) * 1e-6
          dist = nodeWeightSum(path, tsp_data[:weights])
          if (dist < best_dist)
            best_dist = dist
            best_path = path
          end
          push!(results[func]["time"][n], time)
        end
      end
      push!(results[func]["best"][n], best_dist)
      push!(results[func]["prd"][n], prd(best_dist, problems[problem]))
    end
  end

  now = Dates.now()
  isdir("./jsons") || mkdir("./jsons")
  for func in functions
    file_str = "./jsons/$(func)-k$k-$now.json"
    if (func == tabuSearch)
      file_str = "./jsons/$(func)-mv$(String(nameof(mv))[5:end])-s$limit-ts$ts-at$at-bs$bs-sl$sl-t$(Threads.nthreads())-$now.json"
    end
    open(file_str, "w") do io
      JSON.print(io, results[func])
    end;
  end
end