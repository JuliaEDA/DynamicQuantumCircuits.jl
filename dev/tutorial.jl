# # [DynamicQuantumCircuits.jl Tutorial](@id tutorial)

# This tutorial will walk you through the main functionality of the [`DynamicQuantumCircuits.jl`](@ref) package. 
# Specifically, we'll focus on converting a non-unitary optimized quantum circuit into an ideal unitary representation. 
# Latter, we'll focus on verifying the equivalence between a unitary (static) quantum circuit and a non-unitary dynamic quantum circuit.

# First, let's load the required packages and define a sample dynamic quantum circuit:


# ## Circuit conversion Tutorial - copy-pastable version

# ```julia
# using OpenQASM
# using DynamicQuantumCircuits
  
# bv_101_dynamic_qasm = """
#   OPENQASM 2.0;
#   include "qelib1.inc";
#   qreg q[2];
#   creg c[3];
#   x q[1];
#   h q[0];
#   h q[1];
#   CX q[0],q[1];
#   h q[0];
#   measure q[0] -> c[0];
#   reset q[0];
#   h q[0];
#   h q[0];
#   measure q[0] -> c[1];
#   reset q[0];
#   h q[0];
#   CX q[0],q[1];
#   h q[0];
#   measure q[0] -> c[2];
#   """
  
# bv_101_dynamic = OpenQASM.parse(bv_101_dynamic_qasm)
  
# # Convert the non-unitary optimized quantum circuit into an ideal unitary representation
  
# bv_101_dynamic = OpenQASM.parse(bv_101_dynamic_qasm)
  
# Now, we can use the `unitary_reconstruction` function to convert the 
# dynamic quantum circuit into an ideal unitary representation:
  
# bv_101_unitary = DynamicQuantumCircuits.unitary_reconstruction(bv_101_dynamic)
# ```
   
   
# ## Input: an `OpenQASM` file
# First we need to parse the string of the circuit description with OpenQASM
 
using OpenQASM
bv_101_dynamic = OpenQASM.parse("""
    OPENQASM 2.0;
    include "qelib1.inc";
    qreg q[2];
    creg c[3];
    x q[1];
    h q[0];
    h q[1];
    CX q[0],q[1];
    h q[0];
    measure q[0] -> c[0];
    reset q[0];
    h q[0];
    h q[0];
    measure q[0] -> c[1];
    reset q[0];
    h q[0];
    CX q[0],q[1];
    h q[0];
    measure q[0] -> c[2];
    """)
 

# Excellent, let's continue the tutorial and dive deeper into the unitary reconstruction process, focusing on how it overcomes resets and defers measurements.

# # Unitary Reconstruction

# The `unitary_reconstruction` function in `DynamicQuantumCircuits.jl` is responsible for converting a non-unitary optimized quantum circuit (represented as an `OpenQASM` object) into an ideal unitary representation. This process involves several key steps:
  
# 1. **Removing Resets**: Next, the function removes all reset operations from the circuit. This is done using the `remove_resets` function, which drops all `Reset` gates from the circuit's program.
  
# 1. **Deferring Measurements**: After removing measurements and resets, the function defers all remaining measurements to the end of the circuit. This is done using the `defeer_measurements` function, which replaces any phase rotations controlled by measurement outcomes with phase gates controlled by the respective circuits.
  
# 4. **Unitary Reconstruction**: Finally, the function performs the unitary reconstruction by converting the modified circuit into a unitary representation. This is the core of the `unitary_reconstruction` function, which ensures that the resulting circuit is a valid unitary operation.
  
  
# The key advantage of this approach is that it allows the `DynamicQuantumCircuits.jl` package to handle non-unitary circuits, such as those with resets and measurements, and convert them into an equivalent unitary representation. This is crucial for optimizing qubit usage and improving the performance of quantum algorithms on NISQ hardware.
  
# By removing measurements and resets, and deferring the remaining measurements, the unitary reconstruction process ensures that the final circuit is a valid unitary operation, which can then be used in further analysis and optimization.
  
# Let's see the full `unitary_reconstruction` function in action:

using DynamicQuantumCircuits
bv_101_unitary = unitary_reconstruction(bv_101_dynamic)

# This will take the `bv_101_dynamic` circuit, remove measurements and resets, defer measurements, 
# and then perform the unitary reconstruction to obtain the `bv_101_unitary` circuit, which is the ideal unitary representation of the original dynamic circuit.
  
# Now that we have the unitary circuit, we can use the ZX-Calculus to verify its equivalence to the original dynamic circuit, as we did in the previous section.

# ## Equivalence of a static and an ideal quantum circuit

# To verify if the original circuit and the ideal circuit are equal, we can use the libary `ZXCalculus.jl`. The principle of quantum circuit equality relies on the reversibility and unitarity of quantum operations.
  
# Every quantum operation is unitary and thus reversible. The product of any quantum operation and its  inverse (adjoint) will always yield the identity. For a matrix to be unitary, the following property must hold:
  
# ```math
# U \cdot U^\dagger = U^\dagger \cdot U = I_n | U \in \mathbb{R}^{n \times n}
# ```
  
# If `U1` and `U2` are unitary matrices, so is their matrix product `U1 · U2`. Unitary matrices preserve inner products, so if `U` is unitary, then for all `V, V' ∈ ℂ^n` we have:
  
# ```math
# ⟨U V |U V ′ ⟩ = ⟨V |V ′ ⟩
# ```
  
# To verify the equality of two quantum circuits `G1` and `G2` with system matrices `U1` and `U2`, we can check if there is no difference `D = U1 · U2^†` between the first and second quantum circuit. If `tr(D) = 0`, then `U1 · U2^† = D = I`, and the circuits are equal.
  
# Let's use the ZX-Calculus to verify the equivalence of the static and dynamic circuits:
#
# #### Equivalence Checking - copy-pastable version
  
# ```julia
#
# using YaoHIR
# using YaoHIR: BlockIR
# using ZXCalculus
# using ZXCalculus.ZX
# 
# bv_101_static = OpenQASM.parse(""""
#   OPENQASM 2.0;
#   include "qelib1.inc";
#   qreg q[4];
#   creg c[3];
#   x q[3];
#   h q[0];
#   h q[1];
#   h q[2];
#   h q[3];
#   CX q[0],q[3];
#   CX q[2],q[3];
#   h q[0];
#   h q[1];
#   h q[2];
#   measure q[0] -> c[0];
#   measure q[1] -> c[1];
#   measure q[2] -> c[2];
#   """)
  
# bv_101_unitary = DynamicQuantumCircuits.unitary_reconstruction(bv_101_dynamic)
# bv_101_static = ZXDiagram(BlockIR(static))
  
# verify_equality(bv_101_dynamic, bv_101_static)
# ```
  
# This will check if the two ZX-Diagrams representing the static and dynamic circuits are equal, using the powerful rewrite rules of the ZX-Calculus.
  
# ## Verifying the equivalence of static and dynamic circuits

# To compare the original dynamic circuit and the reconstructed unitary circuit, we'll convert them both into ZX-Diagrams and use the `verify_equality` function to check if they are equivalent.
  
# ## Convert the Quantum into a `ZXDiagram`
# Now, we can convert the static and unitary circuits into ZX-Diagrams and verify their equivalence:
 
using YaoHIR
using YaoHIR: BlockIR
using ZXCalculus
using ZXCalculus.ZX

bv_101_static = OpenQASM.parse("""
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q[4];
  creg c[3];
  x q[3];
  h q[0];
  h q[1];
  h q[2];
  h q[3];
  CX q[0],q[3];
  CX q[2],q[3];
  h q[0];
  h q[1];
  h q[2];
  measure q[0] -> c[0];
  measure q[1] -> c[1];
  measure q[2] -> c[2];
  """)


bv_101_dynamic_qasm = OpenQASM.parse("""
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q[2];
  creg c[3];
  x q[1];
  h q[0];
  h q[1];
  CX q[0],q[1];
  h q[0];
  measure q[0] -> c[0];
  reset q[0];
  h q[0];
  h q[0];
  measure q[0] -> c[1];
  reset q[0];
  h q[0];
  CX q[0],q[1];
  h q[0];
  measure q[0] -> c[2];
  """)


bv_101_static_zx = ZXDiagram(BlockIR(bv_101_static))
bv_101_unitary_zx = ZXDiagram(BlockIR(bv_101_unitary))

verify_equality(bv_101_unitary_zx, bv_101_static_zx)

# This will check if the two ZX-Diagrams representing the unitary and static circuits are equal, using the powerful rewrite rules of the ZX-Calculus.
# If the circuits are equivalent, the function will return `true`.

# ## Conclusion

# In this tutorial, we've explored the key functionality of the `DynamicQuantumCircuits.jl` package, which addresses the limitations of Noisy Intermediate-Scale Quantum (NISQ) hardware by reducing qubit count. We've learned how to convert a non-unitary optimized quantum circuit into an ideal unitary representation using the `unitary_reconstruction` function.

# The unitary reconstruction process involves several important steps, such as removing measurements and resets, deferring measurements, and then performing the actual unitary reconstruction. This ensures that the resulting circuit is a valid unitary operation, which is crucial for optimizing qubit usage and improving the performance of quantum algorithms on NISQ hardware.

# We've also seen how to use the powerful ZX-Calculus to verify the equivalence of the static and dynamic circuits. By converting the circuits into ZX-Diagrams and using the `verify_equality` function, we can ensure that the original circuit and the reconstructed unitary circuit are indeed equivalent.

# The `DynamicQuantumCircuits.jl` package provides a valuable tool for researchers and developers working on quantum computing, allowing them to optimize qubit usage and improve the performance of their quantum algorithms on NISQ hardware. 

# We hope this tutorial has been helpful in understanding the capabilities of the `DynamicQuantumCircuits.jl` package and how it can be used to address the challenges of the NISQ era. Happy coding!
