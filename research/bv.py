from qiskit import QuantumCircuit, qasm2
from mqt import qcec


# inspired from https://qmunity.thequantuminsider.com/2024/06/11/bernstein-vazirani-algorithm-with-qiskit/
# and https://scribe.rip/@_monitsharma/learn-quantum-computing-with-qiskit-bernstein-vazirani-algorithm-fa1300517624


def bv_dqc(bitstring):
    """Create a dyamic Berstein-Vazirani circuit from a given bitstring

    parametsers:
        bitstring(str): The hidden bitstring

    Returns:
        QuantumCircuit: Output of the Berstein-Vazirani circuit
    """
    circuit = QuantumCircuit(2, len(bitstring))

    # prepare auxillary qubit in |-> state
    circuit.x(1)
    circuit.barrier()
    circuit.h(1)

    # Build a block for every bit in the bitstring
    # Reverse the bitstring since qiskit is msb
    # Inner-product oracle
    for idx, bit in enumerate(bitstring[::-1]):
        # Add the inital H gate on the control
        circuit.h(0)
        # Add a CNOT if bit is 1
        if int(bit):
            circuit.cx(0, 1)

        # Add the final H gate to convert the phase to the computational basis
        circuit.h(0)

        circuit.barrier()

        # Measure
        circuit.measure(0, idx)

        # If this is not the final qubit add a reset to recycle the qubit
        if idx != (len(bitstring) - 1):
            # Reset the control qubit
            circuit.reset(0)
            # Reset the target qubit to minimize dephasing
            # circuit.reset(1)
            # prepare auxillary qubit in |-> state
            # circuit.x(1)
            # circuit.h(1)

    return circuit


def bv_sqc(bitstring):
    """Create a static Berstein-Vazirani circuit from a given bitstring

    parametsers:
        bitstring(str): The hidden bitstring
        measure(bool): Should measurements be added

    Returns:
        QuantumCircuit: Output of the Berstein-Vazirani circuit
    """

    # Define the cirucit with $n$ qubits and an auxillary qubit
    # Add n classical bits to save the output to
    n = len(bitstring)
    circuit = QuantumCircuit(n + 1, n)

    # prepre auxillary qubit in |-> state
    circuit.x(n)
    circuit.barrier()

    # Apply Hadamard to all gates before quering the gates
    for i in range(n + 1):
        circuit.h(i)

    # TODO do I need a barrier
    circuit.barrier()

    # Inner-product oracle
    # Reverse the bitstring
    s = bitstring[::-1]  # reverse s to fit qiskit's qubit ordering
    for q in range(n):
        if s[q] == "1":
            circuit.cx(q, n)

    # Another barrier
    circuit.barrier()

    # Apply Hadamard ater quering the gates
    for i in range(n):
        circuit.h(i)

    # Add measurements
    for i in range(n):
        circuit.measure(i, i)

    return circuit


def bitstring_to_file(bitstring, dir):
    print(f"Creating {bitstring}")
    n = len(bitstring)
    sqc = bv_sqc(bitstring)
    dqc = bv_dqc(bitstring)
    qasm2.dump(sqc, f"{dir}/BV-{bitstring}_indep_qiskit_{n}.qasm")
    qasm2.dump(dqc, f"{dir}/BV-{bitstring}_dynamic_qiskit_{n}.qasm")


def verify(qc1, qc2, backpropagate_output_permutation=True):
    # print("checking %s, %s", qc1, qc2)
    res = qcec.verify(
        qc1,
        qc2,
        # Optimizations
        transform_dynamic_circuit=True,
        backpropagate_output_permutation=backpropagate_output_permutation,
        # Optional Optimization
        # reconstruct_swaps=True,
        # reorder_operations=True,
        # remove_diagonal_gates_before_measure=True,
        # Execution
        run_alternating_checker=False,
        run_construction_checker=False,
        run_simulation_checker=False,
        run_zx_checker=True,
        nthreads=8,
    )
    print(res)
    return str(res.equivalence) == "equivalent"


def verify_qmdd(qc1, qc2, backpropagate_output_permutation=True):
    # print("checking %s, %s", qc1, qc2)
    res = qcec.verify(
        qc1,
        qc2,
        # Optimizations
        transform_dynamic_circuit=True,
        backpropagate_output_permutation=backpropagate_output_permutation,
        check_partial_equivalence=True,
        nthreads=8,
    )
    print(res)
    return str(res.equivalence) == "equivalent"


def verify_circuits_zx(bitstring):
    print(f"Verifying {bitstring} with zx")
    sqc = bv_sqc(bitstring)
    dqc = bv_dqc(bitstring)
    return verify(sqc, dqc)


def verify_circuits_qmdd(bitstring):
    print(f"Verifying {bitstring} with qmdd")
    sqc = bv_sqc(bitstring)
    dqc = bv_dqc(bitstring)
    return verify_qmdd(sqc, dqc)
