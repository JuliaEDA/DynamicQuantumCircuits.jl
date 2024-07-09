using DynamicQuantumCircuits
using DynamicQuantumCircuits.QuantumInformation
using DynamicQuantumCircuits.Reorder
using DynamicQuantumCircuits: StateVector
using OpenQASM

@testset "calculate quantum information" begin
  input = [1, 0, 0, 0, 0, 0, 0, 0, 0]

  dynamic = """
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q0[2];
  creg mcm[1];
  creg end[1];
  h q0[0];
  x q0[1];
  h q0[1];
  CX q0[0],q0[1];
  h q0[0];
  measure q0[0] -> mcm[0];
  reset q0[0];
  h q0[0];
  CX q0[0],q0[1];
  h q0[0];
  measure q0[0] -> end[0];
  """

  state_vector = StateVector([1, 0], [2])
  ast_dynamic = OpenQASM.parse(dynamic)
  ideal_ast = DynamicQuantumCircuits.unitary_reconstruction(ast_dynamic)
  # TODO readd qasm to operator
  # ideal_operator = Operator.operator_from_qasm(ideal_ast)
  reordered_operator = Reorder.reorder_operator(state_vector, ideal_operator)

  traditional = """
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q0[3];
  creg c0[2];
  h q0[0];
  h q0[1];
  x q0[2];
  h q0[2];
  CX q0[0], q0[2];
  h q0[0];
  measure q0[0] -> c0[0];
  CX q0[1], q0[2];
  h q0[1];
  measure q0[1] -> c0[1];
  """

  traditional_ast = OpenQASM.parse(traditional)

  # TODO readd qasm to operator
  # traditional_operator = Operator.operator_from_qasm(traditional_ast)


  # TODO add jll wrapper for mqt
  # @testset "mqt tests" begin
  #   pyzx_verify(traditional, traditional)
  #   #    ranom_gate()
  #   @info qcec_verify_flow( traditional, false)
  #   @info qcec_verify_zx(traditional, traditional, false)
  #   @info qcec_verify_qmdd(traditional, traditional, false)
  #   @info qcec_verify_qmdd_alternative(traditional, traditional, false)
  #   @info qcec_verify_qmdd_simulation(traditional, traditional, false)
  #   op = operator_from_qasm(OpenQASM.parse(traditional))
  #   graphical_circuit(traditional)
  #   @info simulation_results = aer_simulator_circ(traditional, dynamic)
  #   @info statevecotr_sim_result = state_vector_aer(traditional, dynamic)
  #   depth(traditional)
  #   count_ops(traditional)
  # end

  # TODO readd qasm to operator
  # @testset "calculate fidelity: distance of two operators" begin
  #   # FIXME Add fidelity later
  #   #fidelity = fidelity(reordered_operator, traditional_operator)
  #   distance = qc_trace_distance(traditional_operator, reordered_operator)
  #   @test isapprox(distance, 0; rtol=1e-18) == true
  #   @test distance == 0
  #   #@test fidelity == 1
  # end

  @testset "trivial fidelity example" begin
    X = [0 1; 1 0]
    Y = [0 1; 1 0]
    distance = qc_trace_distance(X, Y)
    @test distance == 0
  end

  @testset "equivalence checking" begin
    @test verify_equivalence(traditional, dynamic, false) == true
    @test verify_equivalence(traditional, dynamic, true) == true
  end
end
