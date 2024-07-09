# # [DynamicQuantumCircuits.jl Tutorial](@id tutorial)
## Circuit conversion
## Convert the non-unitary optimized quantum circuit into an ideal unitary representation
using OpenQASM
using DynamicQuantumCircuits
dynamic_qasm = """
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q0[2];
  creg mcm[1];
  creg end[1];
  h q0[0];
  x q0[1];
  h q0[1];
  CX q0[0],q0[1];
  x q0[0];
  measure q0[0] -> mcm[0];
  reset q0[0];
  h q0[0];
  CX q0[0],q0[1];
  h q0[0];
  measure q0[0] -> end[0];
  """
dynamic = OpenQASM.parse(dynamic_qasm)
static = DynamicQuantumCircuits.unitary_reconstruction(dynamic)

## Equivalence of a static and an ideal quantum circuit

## Verify if the original circuit and the ideal circuit are equal.
## The trace distance is a measure of the closeness of two quantum circuits.
using DynamicQuantumCircuits.QuantumInformation
# TODO add ZXCalculus.jl  and MQT QCEC to support the verification
# distance = verify_equivalence(static, dynamic)
