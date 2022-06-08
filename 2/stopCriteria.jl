using TimesDates

"""
Prepares stop criterion after limit iterations

## Params:
-`limit::Int`: Iterations limit, after that program stops

## Returns:
-`function`: Returns Tuple contatining:
  - `start`: value = 1
  - `predicate`: - function returning boolean if x have surpassed limit
  - `increment`: - function returning x incremented by one
"""
function iterationsCriterion(limit::Int)
  start = 1
  predicate = function(x::Int) return x > limit end
  increment = function(x::Int) return x + 1 end
  return function()
    return (start, predicate, increment)
  end
end

"""
Prepares stop criterion after given time

## Params:
-`timeLimitSeconds::Int`: Time limit in seconds, after that program stops

## Returns:
-`function`: Returns Tuple contatining:
  - `start`: value = 1
  - `predicate`: - function returning boolean if x have surpassed time limit
  - `increment`: - function returning time passed
"""
function timeCriterion(timeLimitSeconds::Int)
  start = time_ns()
  predicate = function(x::UInt64) return (time_ns() - x) * 1e-9 > timeLimitSeconds end
  increment = function(x::UInt64) return x end
  return function()
    return (time_ns(), predicate, increment)
  end
end