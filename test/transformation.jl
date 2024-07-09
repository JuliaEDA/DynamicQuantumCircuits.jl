using DynamicQuantumCircuits
using DynamicQuantumCircuits.Tools
using DynamicQuantumCircuits.Reorder
using DynamicQuantumCircuits.Transformations
using DynamicQuantumCircuits: StateVector



using OpenQASM
using OpenQASM.Types
using RBNF: Token

@testset "reconstruct unitary quantum circuit" begin

  static_trivial = """
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

  ast_static_trivial = OpenQASM.parse(static_trivial)
  println("static_trivial circuit:")
  println(ast_static_trivial)


  dynamic_trivial = """
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


  ast_dynamic_trivial = OpenQASM.parse(dynamic_trivial)
  println("dynamic_trivial circuit:")
  println(ast_dynamic_trivial)

  target_trivial = """
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q0[3];
  creg mcm[1];
  creg end[1];
  h q0[1];
  x q0[2];
  h q0[2];
  CX q0[1],q0[2];
  h q0[1];
  h q0[0];
  CX q0[0],q0[2];
  h q0[0];
  measure q0[0] -> end[0];
  measure q0[1] -> mcm[0];
  """

  ast_target_trivial = OpenQASM.parse(target_trivial)
  println("target_trivial circuit:",)
  println(ast_target_trivial)

  ast = DynamicQuantumCircuits.unitary_reconstruction(ast_dynamic_trivial)
  println("acutal circuit:")
  println(ast)

  measurements = Tools.get_measurements(ast_static_trivial)
  controls = Tools.get_controls(ast_static_trivial)
  num_qubits = Tools.get_num_of_qubits(ast_static_trivial)
  state_vector = Tools.state_vector(ast_dynamic_trivial)

  # TODO work needs to be done to support non unitary in plotting with YaoPlots
  # @testset "show graphical circuits" begin
  #   viz = Operator.graphical_circuit(dynamic_trivial)
  #   @test string(viz) isa String
  # end

  @testset "get new quantum state vector" begin
    @test [state_vector.controls; state_vector.targets] == [1, 0, 2]


    @testset "StateVector qubit address conversion" begin
      @test convert_address(state_vector, 0, 0) == 1
      @test convert_address(state_vector, 0, 1) == 2
      @test convert_address(state_vector, 1, 0) == 0
      @test convert_address(state_vector, 1, 1) == 2
    end

  end

  @testset "measurements" begin
    @test length(measurements) == 2
  end

  @testset "CXGate" begin
    @test length(controls) == 2
  end

  @testset "Numbe of qubits" begin
    @test num_qubits == 3
  end

  @testset "mainprogram" begin
    @test ast isa MainProgram
    @test ast.version == v"2.0.0"
  end

  @testset "quantum RegDecl" begin
    @test ast.prog[2] isa RegDecl
    reg = ast.prog[2]
    @test reg.name isa Token{:id}
    @test reg.name.str == "q0"
    @test reg.size isa Token{:int}
    @test reg.size.str == "3"
    @test reg.type isa Token{:reserved}
    @test reg.type.str == "qreg"
  end

  @testset "Main Programm Equality" begin
    @test ast ≈ ast_target_trivial

  end

  @testset "Prog Equality" begin


    @testset "Section A" begin


      @testset "operation conversion" begin
        # q1[0] h -> 1
        @test ast.prog[5] isa Instruction
        @test ast.prog[5].name == "h"
        @test length(ast.prog[5].qargs) == 1
        @test length(ast.prog[5].cargs) == 0
        @test ast.prog[5].qargs[1].name.str == "q0"
        @test ast.prog[5].qargs[1].address.str == "1"


        # q1[1] x -> 2
        @test ast.prog[6] isa Instruction
        @test ast.prog[6].name == "x"
        @test length(ast.prog[6].qargs) == 1
        @test length(ast.prog[6].cargs) == 0
        @test ast.prog[6].qargs[1].name.str == "q0"
        @test ast.prog[6].qargs[1].address.str == "2"


        #  q1[1] h -> 2
        @test ast.prog[7] isa Instruction
        @test ast.prog[7].name == "h"
        @test length(ast.prog[7].qargs) == 1
        @test length(ast.prog[7].cargs) == 0
        @test ast.prog[7].qargs[1].name.str == "q0"
        @test ast.prog[7].qargs[1].address.str == "2"

        #  q1[0] x -> 1
        @test ast.prog[9] isa Instruction
        @test ast.prog[9].name == "h"
        @test length(ast.prog[9].qargs) == 1
        @test length(ast.prog[9].cargs) == 0
        @test ast.prog[9].qargs[1].name.str == "q0"
        @test ast.prog[9].qargs[1].address.str == "1"
      end


      @testset "control" begin
        @test ast.prog[8] isa CXGate
        cx = ast.prog[8]
        @test cx.ctrl isa Bit
        @test cx.qarg isa Bit
        @test cx.ctrl.name.str == "q0"
        @test cx.qarg.name.str == "q0"
        @test cx.ctrl.address.str == "1"
        @test cx.qarg.address.str == "2"
      end

    end

    @testset "Section B" begin

      @testset "h" begin
        # First q0 h
        @test ast.prog[10] isa Instruction
        @test ast.prog[10].name == "h"
        @test length(ast.prog[10].qargs) == 1
        @test length(ast.prog[10].cargs) == 0
        @test ast.prog[10].qargs[1].name.str == "q0"
        @test ast.prog[10].qargs[1].address.str == "0"


        # second q0 h
        @test ast.prog[12] isa Instruction
        @test ast.prog[12].name == "h"
        @test length(ast.prog[12].qargs) == 1
        @test length(ast.prog[12].cargs) == 0
        @test ast.prog[12].qargs[1].name.str == "q0"
        @test ast.prog[12].qargs[1].address.str == "0"
      end

      @testset "control" begin
        @test ast.prog[11] isa CXGate
        cx = ast.prog[11]
        @test cx.ctrl isa Bit
        @test cx.qarg isa Bit
        @test cx.ctrl.name.str == "q0"
        @test cx.qarg.name.str == "q0"
        @test cx.ctrl.address.str == "0"
        @test cx.qarg.address.str == "2"
      end

      @testset "measure" begin
        m = ast.prog[13]
        @test m isa Measure
        @test m.qarg isa Bit
        @test m.carg isa Bit
        @test m.qarg.name isa Token{:id}
        @test m.qarg.name.str == "q0"
        @test m.carg.name isa Token{:id}
        @test m.carg.name.str == "end"
        @test m.qarg.address isa Token{:int}
        @test m.carg.address isa Token{:int}
        @test m.qarg.address.str == "0"
        @test m.carg.address.str == "0"
      end

      @testset "measure" begin
        m = ast.prog[14]
        @test m isa Measure
        @test m.qarg isa Bit
        @test m.carg isa Bit
        @test m.qarg.name isa Token{:id}
        @test m.qarg.name.str == "q0"
        @test m.carg.name isa Token{:id}
        @test m.carg.name.str == "mcm"
        @test m.qarg.address isa Token{:int}
        @test m.carg.address isa Token{:int}
        @test m.qarg.address.str == "1"
        @test m.carg.address.str == "0"
      end

    end

  end

  # TODO implement a OpenQASM to Operator then readd
  # @testset "convert qasm into operator" begin
  #   operator = Operator.operator_from_qasm(ast)
  #   ideal_operator = Reorder.reorder_operator(state_vector, operator)
  #   static_trivial_operator = Operator.operator_from_qasm(ast_static_trivial)
  #
  #   @testset "process fidelity" begin
  #     # Operator.process_fidelity(static_trivial_operator, ideal_operator)
  #   end
  # end


  @testset "transorm qpe00" begin
    dynamic_qpe = """
    OPENQASM 2.0;
    include "qelib1.inc";
    gate circuit_299 q0,q1 { barrier q0,q1; p(2*pi) q0; p(2*pi) q1; cx q0,q1; p(-2*pi) q1; cx q0,q1; barrier q0,q1; }
    gate circuit_302 q0,q1 { barrier q0,q1; p(pi) q0; p(pi) q1; cx q0,q1; p(-pi) q1; cx q0,q1; barrier q0,q1; }
    qreg q31[2];
    creg c3[2];
    barrier q31[0],q31[1];
    x q31[1];
    barrier q31[0],q31[1];
    h q31[0];
    barrier q31[0],q31[1];
    circuit_299 q31[0],q31[1];
    barrier q31[0],q31[1];
    h q31[0];
    measure q31[0] -> c3[0];
    reset q31[0];
    barrier q31[0],q31[1];
    h q31[0];
    barrier q31[0],q31[1];
    circuit_302 q31[0],q31[1];
    if(c3==1) p(-pi/2) q31[0];
    h q31[0];
    measure q31[0] -> c3[1];
    """

    static_qpe = """
    OPENQASM 2.0;
    include "qelib1.inc";
    gate circuit_250 q0,q1 { barrier q0,q1; p(pi) q0; p(pi) q1; cx q0,q1; p(-pi) q1; cx q0,q1; barrier q0,q1; }
    gate circuit_253 q0,q1 { barrier q0,q1; p(2*pi) q0; p(2*pi) q1; cx q0,q1; p(-2*pi) q1; cx q0,q1; barrier q0,q1; }
    gate circuit_256 q0,q1 { barrier q0,q1; p(-pi/4) q0; p(-pi/4) q1; cx q0,q1; p(pi/4) q1; cx q0,q1; barrier q0,q1; }
    qreg q[3];
    creg c[2];
    barrier q[0],q[1],q[2];
    x q[2];
    barrier q[0],q[1],q[2];
    h q[0];
    h q[1];
    barrier q[0],q[1],q[2];
    circuit_250 q[1],q[2];
    circuit_253 q[0],q[2];
    barrier q[0],q[1],q[2];
    h q[0];
    circuit_256 q[0],q[1];
    h q[1];
    barrier q[0],q[1],q[2];
    measure q[0] -> c[0];
    measure q[1] -> c[1];
    """

    qpe_s_ast = OpenQASM.parse(static_qpe)
    println(qpe_s_ast)
    qpe_d_ast = OpenQASM.parse(dynamic_qpe)
    println(qpe_d_ast)
    # FIXME need to be a cphase gate
    #  qpe_re = DynamicQuantumCircuits.unitary_reconstruction(qpe_d_ast)
    #  println(qpe_re)

  end


  @testset "deferring measurements" begin

    qc_before = OpenQASM.parse("""
    OPENQASM 2.0;
    qreg q[2];
    creg c[2];
    h q[1];
    measure q[0] -> c[0];
    if(c==1) x q[1];
    """)

    qc_deferred_target = OpenQASM.parse("""
    OPENQASM 2.0;
    qreg q[2];
    creg c[2];
    h q[1];
    CX q[0], q[1];
    measure q[0] -> c[0];
    """)

    qc_deferred = MainProgram(qc_before.version, defeer_measurements(qc_before.prog))
    println(qc_deferred)

    @test qc_deferred ≈ qc_deferred_target

  end
end
