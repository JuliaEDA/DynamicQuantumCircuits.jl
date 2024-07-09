module QuantumInformation

using LinearAlgebra
using DynamicQuantumCircuits
using DynamicQuantumCircuits.Reorder
using DynamicQuantumCircuits.Tools
using OpenQASM
using OpenQASM.Types

using SparseArrays

export outer_product, inner_product, fidelity, qc_trace_distance, verify_equivalence



"""
    tracedist(A::Matrix, B::Matrix)::Float64
Return the trace distance of `register1` and `register2`.

# Definition
Trace distance is defined as following:

```math
\\frac{1}{2} || A - B ||_{\\rm tr}
```

### Examples
TODO Doctest


### References

- https://en.wikipedia.org/wiki/Trace_distance
"""
function tracedist(A::Matrix, B::Matrix)::Float64
  eigvals_A = eigen(A).values
  eigvals_B = eigen(B).values

  # Calculate the trace distance
  0.5 * sum(abs.(eigvals_A - eigvals_B))
end


"""
    density_matrix(matrix)::Matrix

Calculate the density matrix assuming phi is the first quantum state in Z Basis


### Definition
```math
M |ϕ⟩ ⟨ϕ| M^\\dagger
```
"""
function density_matrix(matrix)::Matrix
  # Assuming |phi> is the all-zero state
  phi = zeros(Int64, size(matrix, 1))
  phi[1] = 1

  # Calculate the denisty matrix
  matrix * (outer_product(phi, phi)) * adjoint(matrix)
end

"""
    fidelity(U1, U2)::Float64

Fidelity is a measure of distance between quantum states ϕ and ρ


### Definition
The fidelity of two quantum state for qudits is defined as:

```math
F(ϕ, σ) = tr(\\sqrt{\\sqrt{ϕ}ρ\\sqrt{ρ}})
```
"""
function fidelity(U1, U2)::Float64
  abs(sum(conj(U1) .* U2)) / size(U1, 1)
end

function F(U1, U2)
  abs(sum(conj(U1) .* U2)) / size(U1, 1)
end

"""
    equality(M, M_prime)::Float64

Test the equality of two matrices by converting them to density matrices and calculating their trace distance
"""
function qc_trace_distance(M, M_prime)::Float64
  rho = density_matrix(M)
  sigma = density_matrix(M_prime)
  tracedist(rho, sigma)
end

"""
    verify_equivalence(traditional_circuit, dynamic_circuit, use_zx::Bool, transform_dynamic_circuit::Bool)::Float64

Verify the equality of a traditional_circuit and a reconstruced circuit, returning the trace distance and fidelity as a tuple

# TODO change api to differentiate between exact and similar qc
"""
function verify_equivalence(ast_static::MainProgram,
  ast_dynamic::MainProgram, use_zx::Bool=true, transform_dynamic_circuit::Bool=true)::Bool

  # Initialize the circuits
  if transform_dynamic_circuit
    ast_unitary = unitary_reconstruction(ast_dynamic)
  else
    ast_unitary = ast_dynamic
  end
  if use_zx
    equivalence_zx(ast_static, ast_unitary)
  else
    state_vector = Tools.state_vector(ast_dynamic)
    # Create the operators
    ideal_operator = Operator.operator_from_qasm(ast_unitary)
    reordered_operator = sparse(Reorder.reorder_operator(state_vector, ideal_operator))
    traditional_operator = sparse(Operator.operator_from_qasm(ast_static))
    # Calculate the trace distance and return the distance 
    qc_trace_distance(traditional_operator, reordered_operator) ≈ 0
  end
end


function verify_equivalence(static_circuit::String,
  dynamic_circuit::String, useZX::Bool=true, transform_dynamic_circuit::Bool=true)::Bool
  ast_static = OpenQASM.parse(static_circuit)
  ast_dynamic = OpenQASM.parse(dynamic_circuit)
  verify_equivalence(ast_static, ast_dynamic, useZX, transform_dynamic_circuit)
end

"""
    outer_product(x, y)::Matrix


## Definition
```math
(|β⟩) ⋅ (⟨α|) = |β⟩⟨α|
```

``|β⟩⟨α|`` is known as the outer product of ``|β⟩`` and ``⟨α|``. We will emphasize in a moment that |β⟩⟨α|
is to be regarded as an operator; hence it is fundamentally different from the inner product
⟨β|α⟩, which is just a number.

There are also “illegal products.” We have already mentioned that an operator must stand
on the left of a ket or on the right of a bra.

### Examples
TODO Doctest

### Source
(1.46) Quantum Mechanics Book
"""
function outer_product(x, y)::Matrix
  y_dagger = conj(transpose(y))
  x * y_dagger
end

"""
    inner_product(x, y)::Vector

Calculate the inner product


### Examples
The product is written as a bra standing on the left and a ket standing on the right, for example,
```math
  ⟨β|α⟩= (⟨β|) ⋅(|α⟩)
```

TODO Doctest

### Source
(1.46) Quantum Mechanics Book
"""
function inner_product(x, y)::Vector
  y_dagger = conj(transpose(y))
  y_dagger * x
end


end
