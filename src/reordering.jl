module Reorder

using DynamicQuantumCircuits: StateVector

export reorder_operator

"""
    create_bit_matrix(n::Int)::Matrix{Int}

Create matrix for all possible n bit combinations
"""
function create_bit_matrix(bits::Int)::Matrix{Int}
  states = 2^bits
  # This steps creates a states x 1 Matrix with Vectors of length bits
  res = [reverse(digits(n, base=2, pad=bits)) for n in 0:states-1]
  # Hcat flattens the vectors
  # Transpose creates a Matrix of 8x3 of ints
  #return transpose(reshape(reinterpret(Float64, $res), (3, :)))
  # TODO Replace all with Svector
  return transpose(hcat(res...))
end

"""
    reorder_columns(matrix::Matrix{Any}, column_indices::Vector{Int})::Matrix

Reorder matrix based on column_indices


# Example 
```julia-repl
julia> n = 3  # Number of bits
julia> m = create_bit_matrix(n)
julia> m_reordered = reorder_columns(original_matrix, column_indices)
```
"""
function reorder_columns(matrix, column_indices)::Matrix
  indices = [i + 1 for i in column_indices]
  matrix[:, indices]
end


"""
    matrix_row_to_bit(x::Vector{Int})::Int

parses an array of ints as a bit

# Example
```julia-repl
julia> matrix_row_to_bit([0,1,0])
2
```
"""
function matrix_row_to_bit(row)::Int
  parse(Int8, join(string.(row)), base=2)
end

"""
    calulate_indices(state_vector::StateVector)::Array{Int}

Create indices for reordering based

# Example
```julia-repl
julia> calulate_indices(StateVector([1,0], [2]))
Int8[0, 1, 4, 5, 2, 3, 6, 7]
```
"""
function calulate_indices(state_vector::StateVector)::Array{Int}
  sv = [state_vector.controls; state_vector.targets]
  m_indices = reorder_columns(create_bit_matrix(length(sv)), sv)
  # Convert the reordered matrix of possible bit states into the indices, which we use for reordering the operator
  [matrix_row_to_bit(r) for r in eachrow(m_indices)]

end


"""
    reorder_rows(operator, indices)::Matrix

Reorder the rows of a matrix based on the indices
"""
function reorder_rows(operator, indices)::Matrix
  transpose(reorder_columns(transpose(operator), indices))
end

"""
    reorder_operator(operator::Matrix{ComplexF64})::Matrix{ComplexF64}

Calculate the new indices and peform the reordering of an operator
"""
function reorder_operator(state_vector::StateVector, operator)::Matrix{ComplexF64}
  size(operator)[1] == size(operator)[2] || throw(DimensionMismatch("Operator is not a square matrix"))
  operator_qubits = trunc(Int, log2(size(operator)[1]))

  indices = calulate_indices(state_vector)
  length([state_vector.controls; state_vector.targets]) == operator_qubits || throw(
    DimensionMismatch("Operator matrix log2 of its dimension is not equal to the length of the state_vector"))
  reorder_rows(operator, indices)
end


end
