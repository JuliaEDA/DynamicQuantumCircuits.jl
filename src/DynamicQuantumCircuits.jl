module DynamicQuantumCircuits


# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end  DynamicQuantumCircuits

using RBNF
using OpenQASM
using OpenQASM.Tools
using OpenQASM.Types

include("state-vector.jl")
include("tools.jl")
include("transformations.jl")
include("reordering.jl")
include("quantum-information.jl")
include("conversion.jl")

using .Tools: combine
using .Transformations: trans_ast

export unitary_reconstruction


"""
    unitary_reconstruction(qc_dynamic::MainProgram)::MainProgram

Reconstructs a unitary quantum circuit from a dynamic quantum circuit
"""
function unitary_reconstruction(qc_dynamic::MainProgram)::MainProgram
  state_vector = Tools.state_vector(qc_dynamic)
  num_qubits = length(combine(state_vector))
  trans_ast(qc_dynamic, state_vector, num_qubits)

end

"""

    unitary_reconstruction(qc_dynamic::MainProgram)::MainProgram

Reconstructs a unitary quantum circuit from a dynamic quantum circuit
"""
function unitary_reconstruction(qc_dynamic_string::String)::MainProgram
  ast_dynamic = OpenQASM.parse(qc_dynamic_string)
  DynamicQuantumCircuits.unitary_reconstruction(ast_dynamic)
end

end
