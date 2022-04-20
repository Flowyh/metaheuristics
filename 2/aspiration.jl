function mulAspiration(aspiration::Float64, val::Float64)
  result::Float64 = aspiration * val
  result = result > 0.0 ? result : 0.0
  result = result < 1.0 ? result : 1.0
  return result
end

function addAspiration(aspiration::Float64, val::Float64)
  result::Float64 = aspiration + val
  result = result > 0.0 ? result : 0.0
  result = result < 1.0 ? result : 1.0
  return result
end