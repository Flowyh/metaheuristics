include("../2/tabuSearch.jl")
using .TabuSearch: tabuSearch
using TSPLIB
using TimesDates, Dates
import JSON

"""
Generates Dict with key as TSP file name and value as best distance
## returns:
- `Dict` Dict with key as TSP file name and value as best distance.
"""
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

"""
Generates prd for given data.
## returns:
- `Int`: Calculated prd (price-related differential).
"""
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

function testProduceHoney(meadow, flower_size, hive, nectar_estimator, flower_visits_limit, stopCriterion, selection, selection_param)
    test_start = time_ns()
    (_, bestDist::Float64) = produce_honey(
      meadow,
      flower_size,
      hive,
      nectar_estimator,
      flower_visits_limit,
      stopCriterion,
      selection,
      selection_param
    )
    test_end = time_ns()
    return ([], bestDist, (test_end - test_start) * 1e-6)
end

"""
Heuristics test logic for hardcoded set of TSPlib files (see function above).
For tabuSearch in functions array run k tests and save time, best path distance and PRD into results Dict.
Repeat for each problem in hardcoded dict.
Save results to .json file.
## Params
- `functions::Array{Function}` : array of chosen heuristics (see algorithms.jl for available options)
- `k` : number of performed tests for each TSPlib dataset
- `tabu_params` : parameters used in tabuSearch
"""
function beeTSPTest(functions::Array{Function}, k::Int, bees_params::Array{Any})
  results = Dict()
  problems = hardcodedData()

  for func in functions
    results[func] = Dict()
  end

  (bees_count, stopCriterion, stopCritAmount, visits_limit, swarm_generator, swapCount, invertCount, insertCount, selection, selection_param) = bees_params
  # tabu Search params 
  limit = stopCritAmount
  ts = "n2"
  bs = 1000
  at = 0.05
  sl = 1000

  #tabu Size fixed Params

  stop = stopCriterion(stopCritAmount)
  
  for key in keys(results)
    results[key] = Dict("time" => Dict(), "prd" => Dict(), "best" => Dict())
  end

  reg = r"([0-9]+)"
  for problem in collect(keys(problems))
    println("PROBLEM: $problem")
    n = match(reg, problem)[1]
    tsp_data = structToDict(readTSP("./data/all/$problem"))
    current_ts = fld(tsp_data[:dimension], 2)
    current_bs = fld(tsp_data[:dimension], 2)


    for func in functions
      results[func]["time"][n] = []
      results[func]["best"][n] = []
      results[func]["prd"][n] = []
      if (func == tabuSearch)
        path = twoopt(tsp_data)
        #TODO naprawic
        (_, best_dist, time) = testTabuSearch(path, tsp_data[:dimension], tsp_data[:weights], moveInsert, stop, current_ts, at, current_bs, sl)
        push!(results[func]["time"][n], time)
      elseif (func == produce_honey)
        (_, best_dist, time) = testProduceHoney(tsp_data[:weights], tsp_data[:dimension], swarm_generator(bees_count, swapCount, invertCount, insertCount), nodeWeightSum, visits_limit, stop, selection, selection_param)
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

  now = round(Dates.now(), Dates.Second(1))
  isdir("./jsons") || mkdir("./jsons")
  for func in functions
    file_str = "./jsons/$(func)-k$k-$now.json"
    if (func == tabuSearch)
      file_str = "./jsons/$(func)-k$k-mvInsert-st$limit-ts$ts-at$at-bs$bs-sl$sl-t$(Threads.nthreads())-$now.json"
    elseif (func == produce_honey)
      if (100 == swapCount + invertCount + insertCount)
        file_str = "./jsons/artificialBeeColony-k$k-bc$bees_count-sc$(String(nameof(stopCriterion)))-sl-$stopCritAmount-vl$visits_limit-sg$(swapCount)_$(invertCount)_$(insertCount)-sm$(String(nameof(selection)))-sp$(selection_param)-$now.json"
      else
        file_str = "./jsons/artificialBeeColony-k$k-bc$bees_count-sc$(String(nameof(stopCriterion)))-sl-$stopCritAmount-vl$visits_limit-sg$(String(nameof(swarm_generator)))-sm$(String(nameof(selection)))-sp$(selection_param)-$now.json"
      end
    end
    open(file_str, "w") do io
      JSON.print(io, results[func])
    end;
  end
end

function beeRandomTest(
  functions::Array{Function}, 
  k::Int, 
  start::Int, 
  step::Int, 
  s_end::Int, 
  random::Function, 
  bees_params::Array{Any}
)
  results = Dict()

  for func in functions
    results[func] = Dict()
  end

  (bees_count, stopCriterion, stopCritAmount, visits_limit, swarm_generator, swapCount, invertCount, insertCount, selection, selection_param) = bees_params
  # tabu Search params 
  limit = stopCritAmount
  ts = "div2"
  bs = 1000
  at = 0.05
  sl = 1000

  
  stop = stopCriterion(stopCritAmount)
  
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
    current_ts = fld(tsp_data[:dimension], 2)
    current_bs = fld(tsp_data[:dimension], 2)

    for func in functions
      results[func]["time"][n] = []
      results[func]["best"][n] = []
      results[func]["prd"][n] = []
      if (func == tabuSearch)
        path = twoopt(tsp_data)
        #TODO zmienic
        (_, best_dist, time) = testTabuSearch(path, tsp_data[:dimension], tsp_data[:weights], moveInsert, stop, current_ts, at, current_bs, sl)
        push!(results[func]["time"][n], time)
      elseif (func == produce_honey)
        (_, best_dist, time) = testProduceHoney(tsp_data[:weights], tsp_data[:dimension], swarm_generator(bees_count,swapCount, invertCount, insertCount), nodeWeightSum, visits_limit, stop, selection, selection_param)
        push!(results[func]["time"][n], time)
      else
        best_path = krandom(tsp_data, 1)
        best_dist = nodeWeightSum(best_path, tsp_data[:weights])
        for _ in 1:k
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
      best_dist_funcs[func] = best_dist
      best_func = (best_func > best_dist ? best_dist : best_func)
      push!(results[func]["best"][n], best_dist)
    end
    for func in functions
      push!(results[func]["prd"][n], prd(best_dist_funcs[func], best_func))
    end
  end

  now = round(Dates.now(), Dates.Second(1))
  isdir("./jsons") || mkdir("./jsons")
  for func in functions
    file_str = "./jsons/$(func)-r$(String(nameof(random))[9:end])-k$k-b$start-s$step-e$s_end-$now.json"
    if (func == tabuSearch)
      file_str = "./jsons/$(func)-r$(String(nameof(random))[9:end])-k$k-b$start-s$step-e$s_end--mvInsert-st$limit-ts$ts-at$at-bs$bs-sl$sl-t$(Threads.nthreads())-$now.json"
    elseif (func == produce_honey)
      if (100 == swapCount + invertCount + insertCount)
        file_str = "./jsons/artificialBeeColony-r$(String(nameof(random))[9:end])-k$k-b$start-s$step-e$s_end-bc$bees_count-sc$(String(nameof(stopCriterion)))-sl-$stopCritAmount-vl$visits_limit-sg$swapCount,$invertCount,$insertCount-sm$(String(nameof(selection)))-sp$(selection_param)-t$(Threads.nthreads())-$now.json"
      else
        file_str = "./jsons/artificialBeeColony-r$(String(nameof(random))[9:end])-k$k-b$start-s$step-e$s_end-bc$bees_count-sc$(String(nameof(stopCriterion)))-sl-$stopCritAmount-vl$visits_limit-sg$(String(nameof(swarm_generator)))-sm$(String(nameof(selection)))-sp$(selection_param)-t$(Threads.nthreads())-$now.json"
      end
    end
    open(file_str, "w") do io
      JSON.print(io, results[func])
    end;
  end
end