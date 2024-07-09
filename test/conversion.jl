using DynamicQuantumCircuits
using DynamicQuantumCircuits.Tools
using DynamicQuantumCircuits.Reorder
using DynamicQuantumCircuits: StateVector



using OpenQASM
using OpenQASM.Types
using RBNF: Token

@testset verbose = true "convert simple quantum circuit into ideal quantum circuit" begin

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

  ast_traditional = OpenQASM.parse(traditional)
  println("traditional circuit:")
  println(ast_traditional)


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

  ast_dynamic = OpenQASM.parse(dynamic)
  println("dynamic circuit:")
  println(ast_dynamic)

  target = """
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
  measure q0[1] -> mcm[0];
  h q0[0];
  CX q0[0],q0[2];
  h q0[0];
  measure q0[0] -> end[0];
  """

  ast_target = OpenQASM.parse(target)
  println("target circuit:",)
  println(ast_target)

  ast = DynamicQuantumCircuits.unitary_reconstruction(ast_dynamic)
  println("actual circuit:")
  println(ast)

  measurements = Tools.get_measurements(ast_traditional)
  controls = Tools.get_controls(ast_traditional)
  num_qubits = Tools.get_num_of_qubits(ast_traditional)
  state_vector = Tools.state_vector(ast_dynamic)

  # TODO add visualisation libary
  # @testset "show graphical circuits" begin
  #   viz = Operator.graphical_circuit(dynamic)
  #   @test string(viz) isa String
  # end

  @testset "get new quantum state vector" begin
    #state_vector = Tools.create_state_vector(num_qubits, measurements, controls)
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
    @test ast ≈ ast_target

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



      @testset "measure" begin
        m = ast.prog[10]
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

    @testset "Section B" begin

      @testset "h" begin
        # First q0 h
        @test ast.prog[11] isa Instruction
        @test ast.prog[11].name == "h"
        @test length(ast.prog[11].qargs) == 1
        @test length(ast.prog[11].cargs) == 0
        @test ast.prog[11].qargs[1].name.str == "q0"
        @test ast.prog[11].qargs[1].address.str == "0"


        # second q0 h
        @test ast.prog[13] isa Instruction
        @test ast.prog[13].name == "h"
        @test length(ast.prog[13].qargs) == 1
        @test length(ast.prog[13].cargs) == 0
        @test ast.prog[13].qargs[1].name.str == "q0"
        @test ast.prog[13].qargs[1].address.str == "0"
      end

      @testset "control" begin
        @test ast.prog[12] isa CXGate
        cx = ast.prog[12]
        @test cx.ctrl isa Bit
        @test cx.qarg isa Bit
        @test cx.ctrl.name.str == "q0"
        @test cx.qarg.name.str == "q0"
        @test cx.ctrl.address.str == "0"
        @test cx.qarg.address.str == "2"
      end



      @testset "measure" begin
        m = ast.prog[14]
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

    end

  end

  # @testset "convert qasm into operator" begin
  #   operator = Operator.operator_from_qasm(ast)
  #   ideal_operator = Reorder.reorder_operator(state_vector, operator)
  #   traditional_operator = Operator.operator_from_qasm(ast_traditional)
  #
  #   @testset "process fidelity" begin
  #     # Operator.process_fidelity(traditional_operator, ideal_operator)
  #   end
  # end



end
