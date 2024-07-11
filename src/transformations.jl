module Transformations

using OpenQASM
using OpenQASM.Types
using Moshi.Match: @match

using RBNF: Token
using ..Tools
using ..Tools: StateVector

export trans_ast, remove_measurements, remove_resets, defeer_measurements

"""
    remove_measurements(ast::MainProgram)::MainProgram

Removes all measurements from a quantum circuit
"""
function remove_measurements(ast::MainProgram)::MainProgram
  prog = Tools.drop_gate_of_type(ast.prog, Measure)
  MainProgram(ast.version, prog)
end

"""
    acts_on?(operation::Any, qubit::Bit)

Does the operation act on the qubit
"""
function acts_on(operation::Any, qubit::Bit)
  @match operation begin
    o::Measure => any(operation.qargs, qubit)
    r::Reset => any(operation.qargs, qubit)
    _ => false
  end
end


"""
    defeer_measurements(prog::Vector{Any})::Vector{Any}

Delay all meausrements to the end and replace phase roations controlled by meausrement outcomes
with phase gates controlled by the respective circuits
"""
function defeer_measurements(prog::Vector{Any})::Vector{Any}
  qubits_to_measure = Dict()
  prog_length = length(prog)
  #@info "deffering measurements for $prog"
  for (index, p) in enumerate(prog)
    #@info "current gate is $p "
    if p isa Measure
      #@info "... found meausrement gate with carg $(p.carg)"
      # break when this is the last operation
      #@info index
      #@info prog_length
      length(prog) != index || break

      measurement_qubit = p.qarg
      measurement_bit = p.carg

      # Remember the the classical bit
      push!(qubits_to_measure, measurement_bit => measurement_qubit)

      # Remove the measurement 
      deleteat!(prog, findall(x -> x == p, prog))

      insertion_point = index

      #@info prog[index:length(prog)]

      # Remeber that the array just shrank
      # prog[index] was prog[index+1] before
      for j in index:length(prog)
        p_op = prog[j]
        #@info "    looking for replacement"
        if p_op isa Instruction || p_op isa Barrier
          #@info "     found Instruction or Barrier"

          # if the operation does not act on the measured qubit, increase the insertion_point
          if !acts_on(p_op, measurement_qubit)
            #@info "    $p atcts on $p_op"
            insertion_point += 1
          end
          continue
        end

        if p_op isa Reset
          throw(ArgumentError("reset found while defering measurements, eliminate resets before deferring measurments"))
        end

        if p_op isa Measure
          #@info "     found Measure"
          # Has a break point been reached?
          if measurement_qubit == p.qarg && measurement_bit == p.qarg
            break
          end

          # TODO why is this important
          insertion_point += 1
          continue
        end

        if p_op isa IfStmt
          if measurement_bit.name.str == p_op.left.str
            #@info "    found corresponding IfStmt $p_op"
            if p_op.right.str != "1"
              throw(ArgumentError("$p_op does not check if classical register is 1"))
            end
            #@info p_op.body.name
            if p_op.body.name != "x"
              throw(ArgumentError("$p_op if_stmt does not containd an x"))
              # elseif measurement_qubit == p_op.body.qargs[1]
            else
              #@info "    replace with CXGate"
              c_op = CXGate(qubits_to_measure[measurement_bit], p_op.body.qargs[1])
              prog[j] = c_op
            end
          end

        end

      end
    end
  end
  for (carg, qarg) in qubits_to_measure
    push!(prog, Measure(qarg, carg))
  end
  prog
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
    trans_ast(ast::MainProgram, state_vector::StateVector, num_qubits::Int64)::MainProgram

transform the dynamic primitives to unveil the underlying unitary functionality

# How
1. Overcome resets
2. Apply the /defered measurement principle/

"""
function trans_ast(ast::MainProgram, state_vector::StateVector, num_qubits::Int64)::MainProgram
  prog = overcome_resets(ast, state_vector, num_qubits)
  prog = defeer_measurements(prog)
  MainProgram(ast.version, prog)
end


"""
    overcome_resets(ast::MainProgram, state_vector::StateVector, num_qubits::Int64)::Vector{Any}

overcomes resets operations by eliminating qubit reuse

This transforms a n qubit circuit circuit containing r reset operations into a 
n+r qubit quantum circuits

# Algorithm
Overcome resets by interpreting a reset as measuring a qubit and applying an X operation 
on the measurement being |1⟩ and discarding the measurement result. To overcome the 
resets replace by introducing a new qubit and applying subsequent operations involving the 
qubit to the new qubit
"""
function overcome_resets(ast::MainProgram, state_vector::StateVector, num_qubits::Int64)::Vector{Any}
  prog_sections = zip_prog_section(ast.prog)
  prog = [trans_prog(p[1], state_vector, num_qubits, p[2]) for p in prog_sections]
  Tools.drop_gate_of_type(prog, Reset)
end

"""
    trans_prog(a::Any, state_vector::StateVector, num_qubits::Int, section::Int)::Any

Pattern matches a Prog element and returns it with the new address, based on the transformation
from the StateVector
"""
function trans_prog(a::Any, state_vector::StateVector, num_qubits::Int, section::Int)::Any
  @match a begin
    # Idenity
    i::Include => i
    g::Gate => g

    # Transformations
    r::RegDecl => trans_regdecl(r, num_qubits) # Fixme increase register size
    inst::Instruction => trans_qop(inst, state_vector, section)
    cx::CXGate => trans_qop(cx, state_vector, section)
    m::Measure => trans_qop(m, state_vector, section)
    r::Reset => trans_qop(r, state_vector, section)
    i::IfStmt => trans_if_stmt(i, state_vector, section)
    b::Barrier => trans_barrier(b, state_vector, section)


    # Not supported
    i => throw(ArgumentError("$i \n with type $(typeof(i)) is not yet supported "))
  end
end


function trans_barrier(barrier::Barrier, state_vector::StateVector, section::Int)::Barrier
  Barrier([create_bit(state_vector, i, section) for i in barrier.qargs])
end

"""
    trans_if_stmt(stmt, state_vector, section)

transforms the qargs of a IfStmt
"""
function trans_if_stmt(stmt::IfStmt, state_vector::StateVector, section::Int)::IfStmt
  qargs = [create_bit(state_vector, i, section) for i in stmt.body.qargs]
  body = Instruction(stmt.body.name, stmt.body.cargs, qargs)
  IfStmt(stmt.left, stmt.right, body)
end

"""
    trans_regdecl(reg::RegDecl, num_qubits::Integer)::RegDecl

Sets num_qubits bits as the number of bits in a quantum RegDecl
"""
function trans_regdecl(reg::RegDecl, num_qubits::Integer)::RegDecl
  @match reg begin
    if reg.type.str == "qreg"
    end => RegDecl(Token{:reserved}("qreg"), Token{:id}(reg.name.str), Token{:int}(string(num_qubits)))
    creg => creg
  end
end


"""
    trans_qop(inst::Instruction, state_vector::StateVector, section::Int)::Instruction

transforms the adresses of a quantum operation based on the state vector and section in the dynamic circuit.
"""
function trans_qop(inst::Instruction, state_vector::StateVector, section::Int)::Instruction
  cargs = [create_bit(state_vector, i, section) for i in inst.cargs]
  qargs = [create_bit(state_vector, i, section) for i in inst.qargs]
  Instruction(inst.name, cargs, qargs)
end

"""
    trans_qop(cx::CXGate, state_vector::StateVector, section::Int)::CXGate

transforms the adresses of a CXGate based on the state vector and section in the dynamic circuit.
"""
function trans_qop(cx::CXGate, state_vector::StateVector, section::Int)::CXGate
  ctrl = create_bit(state_vector, cx.ctrl, section)
  qarg = create_bit(state_vector, cx.qarg, section)
  CXGate(ctrl, qarg)
end

"""
    trans_qop(m::Measure, state_vector::StateVector, section::Int)::Measure

transforms the adresses of a Meausment Operation based on the state vector and section in the dynamic circuit.
"""
function trans_qop(m::Measure, state_vector::StateVector, section::Int)::Measure
  # Keep old cargs, since they are not changed
  qarg = create_bit(state_vector, m.qarg, section) # Increment after measure
  Measure(qarg, m.carg)
end

"""
    trans_qop(r::Reset, state_vector::StateVector, section::Int)::Reset

Return the Reset Operation unchanged

FIXME check if this is according to specifaction
"""
function trans_qop(r::Reset, state_vector::StateVector, section::Int)::Reset
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
