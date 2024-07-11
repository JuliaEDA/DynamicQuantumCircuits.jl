module Conversion

using OpenQASM
using OpenQASM.Types
using Moshi.Match: @match

using RBNF: Token
using ..Tools
using ..Tools: StateVector

export conv_ast, remove_measurements, remove_resets

"""
    remove_measurements(ast::MainProgram)::MainProgram

Removes all measurements from a quantum circuit
"""
function remove_measurements(ast::MainProgram)::MainProgram
  prog = Tools.drop_gate_of_type(ast.prog, Measure)
  MainProgram(ast.version, prog)
end

"""
    remove_resets(ast::MainProgram)::MainProgram

Removes all resets from a quantum circuit
"""
function remove_resets(ast::MainProgram)::MainProgram
  prog = Tools.drop_gate_of_type(ast.prog, Reset)
  MainProgram(ast.version, prog)
end

"""
    conv_ast(ast::MainProgram, state_vector::StateVector, num_qubits::Int64)::MainProgram

Converts a non-unitary quantum circuit so it can be tested for equality with  its equivalent a unitary circuit
"""
function conv_ast(ast::MainProgram, state_vector::StateVector, num_qubits::Int64)::MainProgram
  prog_sections = zip_prog_section(ast.prog)
  prog = [conv_prog(p[1], state_vector, num_qubits, p[2]) for p in prog_sections]
  prog = Tools.drop_gate_of_type(prog, Reset)
  MainProgram(ast.version, prog)
end

"""
    conv_prog(a::Any, state_vector::StateVector, num_qubits::Int, section::Int)::Any

Pattern matches a Prog element and returns it with the new address, based on the conversion from the StateVector
"""
function conv_prog(a::Any, state_vector::StateVector, num_qubits::Int, section::Int)::Any
  @match a begin
    i::Include => i
    r::RegDecl => conv_regdecl(r, num_qubits) # Fixme increase register size
    inst::Instruction => conv_qop(inst, state_vector, section)
    cx::CXGate => conv_qop(cx, state_vector, section)
    m::Measure => conv_qop(m, state_vector, section)
    r::Reset => conv_qop(r, state_vector, section)
  end
end

"""
    conv_regdecl(reg::RegDecl, num_qubits::Integer)::RegDecl

Sets num_qubits bits as the number of bits in a quantum RegDecl
"""
function conv_regdecl(reg::RegDecl, num_qubits::Integer)::RegDecl
  @match reg begin
    if reg.type.str == "qreg"
    end => RegDecl(Token{:reserved}("qreg"), Token{:id}(reg.name.str), Token{:int}(string(num_qubits)))
    creg => creg
  end
end


"""
    conv_qop(inst::Instruction, state_vector::StateVector, section::Int)::Instruction

Converts the adresses of a quantum operation based on the state vector and section in the dynamic circuit.
"""
function conv_qop(inst::Instruction, state_vector::StateVector, section::Int)::Instruction
  cargs = [create_bit(state_vector, i, section) for i in inst.cargs]
  qargs = [create_bit(state_vector, i, section) for i in inst.qargs]
  Instruction(inst.name, cargs, qargs)
end

"""
    conv_qop(cx::CXGate, state_vector::StateVector, section::Int)::CXGate

Converts the adresses of a CXGate based on the state vector and section in the dynamic circuit.
"""
function conv_qop(cx::CXGate, state_vector::StateVector, section::Int)::CXGate
  ctrl = create_bit(state_vector, cx.ctrl, section)
  qarg = create_bit(state_vector, cx.qarg, section)
  CXGate(ctrl, qarg)
end

"""
    conv_qop(m::Measure, state_vector::StateVector, section::Int)::Measure

Converts the adresses of a Meausment Operation based on the state vector and section in the dynamic circuit.
"""
function conv_qop(m::Measure, state_vector::StateVector, section::Int)::Measure
  # Keep old cargs, since they are not changed
  qarg = create_bit(state_vector, m.qarg, section) # Increment after measure
  Measure(qarg, m.carg)
end

"""
    conv_qop(r::Reset, state_vector::StateVector, section::Int)::Reset

Return the Reset Operation unchanged

FIXME check if this is according to specifaction
"""
function conv_qop(r::Reset, state_vector::StateVector, section::Int)::Reset
  return r
end

# TODO add for uop, Gate
#
"""
    zip_prog_section(progs::Vector{Any})

Zip the index of each section with a prog element. Increment index after each Measure
"""
function zip_prog_section(progs::Vector{Any})
  result = []
  section = 0

  for item in progs
    push!(result, (item, section))
    if item isa Measure
      section += 1
    end
  end

  return result
end


"""
    create_bit(state_vector::StateVector, i::Bit)::Bit

Create a Bit from a the state vector and the old bit adress
"""
function create_bit(state_vector::StateVector, i::Bit, section::Int)::Bit
  Bit(i.name.str, convert_address(state_vector, section, parse(Int64, i.address.str)))::Bit
end



end
