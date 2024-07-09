export StateVector, validate_state

struct StateVector

  # TODO what about changing the basis from Z to X +, - or Y left or right
  controls::Vector{Any}
  targets::Vector{Any}

  #  function StateVector(upper::Vector{Any}, lower::Vector{Any}) 
  #    validate_state(upper, lower) ? new(upper, lower) : throw(ArgumentError("upper ⨥ lower needs to be a Set"))
  #  end

end

"""
    validate_state(upper::Vector{Any}, lower::Vector{Any})

The combined StateVector needs to be a Set
# TODO Check if the the states are increase by one
"""
function validate_state(upper::Vector{Any}, lower::Vector{Any})
  length([lower; upper]) == length(unique([lower; upper]))
end


