"""
Multiplies value with aspiration

## Params:
- `aspiration::Float64`: Current aspiration
- `val::Float64`: Value to add to aspiration

## Returns:
- `result::Float64`: New aspiration

"""
function mulAspiration(aspiration::Float64, val::Float64)
  result::Float64 = aspiration * val
  result = result > 0.0 ? result : 0.0
  result = result < 1.0 ? result : 1.0
  return result
end

"""
Adds value to aspiration

## Params:
- `aspiration::Float64`: Current aspiration
- `val::Float64`: Value to add to aspiration

## Returns:
- `result::Float64`: New aspiration

"""
function addAspiration(aspiration::Float64, val::Float64)
  result::Float64 = aspiration + val
  result = result > 0.0 ? result : 0.0
  result = result < 1.0 ? result : 1.0
  return result
end