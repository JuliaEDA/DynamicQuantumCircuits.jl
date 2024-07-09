module Tools

export convert_address, state_vector, read_qasm_from_file, drop_gate_of_type, prepare_for_ZXCalculus, randomize_instruction

using MLStyle
using OpenQASM
using OpenQASM.Types
using OpenQASM.Tools
using DynamicQuantumCircuits: StateVector

function randomize_instruction(ast::MainProgram)
  progs = copy(ast.prog)
  p = filter(x -> typeof(x) == Instruction, progs)[1]
  index = findfirst(x -> x == p, ast.prog)

  new_name = @match p.name begin
    "x" => "h"
    "h" => "x"
    "y" => "s"
    "s" => "x"
    _ => "x"
  end

  ins = Instruction(new_name, p.cargs, p.qargs)
  progs[index] = ins
  return MainProgram(ast.version, progs)

end



"""
    combine(s::StateVector)::Array{Int}

Return the combined states of the state vector
"""
function combine(s::StateVector)::Array{Int}
  [s.controls; s.targets]
end



"""
    convert_address(state::State, section::Int, address::Int)::Int64

Replaces the address of a qubit based on the state vector, section and position using a lookup table

# Objective
This function converts old addresses into new addresses required for the ideal unitary circuit
"""
function convert_address(state::StateVector, section::Int, address::Int)::Int64
  # No matter how many control operations there are, always use the correct index for the target array
  #print("conv_add $section $address offset: c=$(state.controls) t=$(state.targets) = ")
  # Create Tuple, so I can use adress to index target or control of the dynamic circuit
  sv = (state.controls, state.targets)

  addr = sv[address+1][(section%=length(sv[address+1]))+1]
  return addr
end

"""
    state_vector(ast::MainProgram)::StateVector

Creates the reordered StateVector based on the ast of a quantum circuit
"""
function state_vector(ast::MainProgram)::StateVector
  m = get_measurements(ast)
  # FIXME what to do, when there is entanglement and more than 2 qubits
  StateVector(reverse([i for i in 0:(length(m)-1)]), [length(m)])


end

"""
    read_qasm_from_file(filename)::String

Read the qasm from a file
"""
function read_qasm_from_file(filename)::String
  s = open(filename) do file
    read(file, String)
  end
  s
end

"""
    get_measurements(ast :: MainProgram)::Array{Measure}

Return all measurement operations of the quantum circuit
"""
function get_measurements(ast::MainProgram)::Array{Measure}
  [m for m in ast.prog if m isa Measure]
end

"""
    get_controls(ast :: MainProgram)::Array{CXGate}

Return all control operations of the quantum circuit
"""
function get_controls(ast::MainProgram)::Array{CXGate}
  [c for c in ast.prog if c isa CXGate]
end

"""
    get_num_of_qubits(ast :: MainProgram)::Int

Returns the number of qubits, which have been specified in the first quantum register
"""
function get_num_of_qubits(ast::MainProgram)::Int
  sum([parse(Int64, r.size.str) for r in ast.prog
       if r isa RegDecl && r.type.str == "qreg"])
end


"""
    drop_gate_of_type(arr, gate_type::Type)

Filters any gate which matches the gate type
"""
function drop_gate_of_type(arr, gate_type::Type)::Array{Any}
  return filter(item -> !(isa(item, gate_type)), arr)
end

"""
    prepare_for_ZXCalculus(ast::MainProgram)

preparre for import in the ZXCalculus by removing measurements, barriers and #TODO applying custom gates
"""
function prepare_for_ZXCalculus(ast::MainProgram)
  prog = drop_gate_of_type(ast.prog, Barrier)
  prog = drop_gate_of_type(prog, Measure)
  MainProgram(ast.version, prog)
end
end
