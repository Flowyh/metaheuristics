# stop_criterion -> (statystyke, function predykat, function updateStatystyki)
# czas_criterion -> (time_left, time_exceeded, updateTime)
# TabuSearch(..., czas_criterion(5 minut))

# Kryteria:
# Czas - Max i start
# Ilosc cykli - n
# Limit wywolan funkcji celu - n
# Stagnacja - n cykli -> reset jakos idk

# stop_criterion -> (statystyke, function predykat, function updateStatystyki)
# czas_criterion -> (time_left, time_exceeded, updateTime)
# TabuSearch(..., czas_criterion(5 minut))

using TimesDates

function iterationsCriterion(limit::Int)
  start = 1
  predicate = function(x::Int) return x > limit end
  increment = function(x::Int) return x + 1 end
  return function()
    return (start, predicate, increment)
  end
end

function timeCriterion(timeLimitSeconds::Int)
  start = time_ns()
  predicate = function(x::UInt64) return (time_ns() - x) * 1e-9 > timeLimitSeconds end
  increment = function(x::UInt64) return x end
  return function()
    return (start, predicate, increment)
  end
end