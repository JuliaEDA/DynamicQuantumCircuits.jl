### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
  quote
    local iv = try
      Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value
    catch
      b -> missing
    end
    local el = $(esc(element))
    global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
    el
  end
end

# ╔═╡ 5d126c90-4711-11ee-0f12-e51f3cfa747f
# ╠═╡ show_logs = false
begin
  import Pkg

  Pkg.activate("/tmp/tmp-3dsgfsdw")
  #Pkg.add(path="/home/liam/src/quantum-circuits/impl/DynamicQuantumCircuits")
  Pkg.add(url="https://github.com/Roger-luo/Expronicon.jl")
  Pkg.add(url="https://github.com/JuliaCompilerPlugins/CompilerPluginTools.jl")
  Pkg.add(url="/home/liam/src/qc2/software/DynamicQuantumCircuits.jl")

  Pkg.add(url="https://github.com/contra-bit/YaoHIR.jl", rev="feature/OpenQASM")
  Pkg.add(url="https://github.com/contra-bit/OpenQASM.jl.git", rev="feature/czgate")
  Pkg.add(url="https://github.com/QuantumBFS/YaoLocations.jl", rev="master")
  Pkg.add(url="https://github.com/QuantumBFS/Multigraphs.jl")
  Pkg.add(url="https://github.com/contra-bit/ZXCalculus.jl", rev="feat/convert_to_zxwd")
  Pkg.add("PlutoUI")
  # AST Circuit Transformtation
  using DynamicQuantumCircuits
  using OpenQASM

  # ZX Calculus Tools
  using ZXCalculus
  using YaoHIR, YaoLocations
  using YaoHIR.IntrinsicOperation
  using CompilerPluginTools

  # Pluto Tools
  using PlutoUI
end

# ╔═╡ dfdd5c22-3981-46d0-9b2d-63f513b3c7a9
function Base.show(io::IO, mime::MIME"text/html", zx::Union{ZXDiagram,ZXGraph})
  g = plot(zx)
  Base.show(io, mime, g)
end

# ╔═╡ e96a8b36-6330-439c-a856-dd8bee840b39
md"""
### Define the traditional quantum circuit here:
"""

# ╔═╡ 2af6819a-0494-484f-9a8a-5d8efd0cf389
@bind traditional_quantum_circuit TextField(
  (30, 15),
  """
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
measure q0[1] -> c0[1];"""
)

# ╔═╡ 38429f6b-8e57-40b7-a918-df3ac4fa4ea1
Operator.graphical_circuit(traditional_quantum_circuit)

# ╔═╡ f1871b30-0bd8-48d2-9e2d-9b8e1e82b6cd
begin
  bir_original = BlockIR(traditional_quantum_circuit)
  zxd_original = ZXDiagram(bir_original)
end

# ╔═╡ 6dd31586-53cc-4315-a16d-28354a06d328
md"""
### Define the dynamic quantum circuit here:
"""

# ╔═╡ 18a83713-4cff-48e6-a9af-eeb221d65abf
@bind dynamic_quantum_circuit TextField(
  (30, 15),
  """
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
)

# ╔═╡ 33bdf1a7-df06-422f-a817-20cf0e0763d3
Operator.graphical_circuit(dynamic_quantum_circuit)

# ╔═╡ 4ca57f9e-ef59-4f7c-8cf8-91c7d2f9aba5
md"""
### Transpiled Unitary Circuit
"""

# ╔═╡ 7622cc39-8e29-42b4-af93-60abf8fabb3a
begin
  transpiled_circuit = DynamicQuantumCircuits.ideal_quantum_circuit(dynamic_quantum_circuit)
  Operator.graphical_circuit(string(transpiled_circuit))
end

# ╔═╡ e3fa781e-ff02-4d9c-b314-049a92e92882
begin
  bir_transpiled = BlockIR(transpiled_circuit)
  zxd_transpiled = ZXDiagram(bir_transpiled)
  pushfirst_gate!(zxd_transpiled, Val{:SWAP}(), [1, 2])
end

# ╔═╡ 01de9f1d-0307-4813-be15-df6f56cbeea5
md"""
## Operator Based Equivalence Checking
"""

# ╔═╡ 654e0826-5a4b-4b3b-bc36-cae10a479598
verify_equivalence(traditional_quantum_circuit, dynamic_quantum_circuit)

# ╔═╡ 0f800969-86a4-44c6-9fc2-021b8282ae8f
zxwd_original = convert_to_zxwd(bir_original)

# ╔═╡ 8dc81bcb-d558-4ceb-9269-35ccd86c984d
begin
  zxwd_transpiled = convert_to_zxwd(bir_transpiled)
  push_gate!(zxwd_transpiled, Val{:SWAP}(), [1, 2])
end

# ╔═╡ 9d73b2aa-5b1a-4474-9264-655402599ecd
md"""
## ZX Calculus Equivalence Checking
First lets convert the Diagrams into their Matrix Representation.
Here is matrix for the original quantum circuit:
"""

# ╔═╡ 637d5a6e-56ee-4149-a9cd-4a8784c53556
m_o = Matrix(zxwd_original)

# ╔═╡ ceac9e0d-5a86-4565-abfe-ba19d05433ca
md"""
Here is the matrix for the transpiled circuit:
"""

# ╔═╡ 6b0087a2-e821-4195-808d-09d46b755380
m_t = Matrix(zxwd_transpiled)

# ╔═╡ ecd5d804-0c51-44d7-ae0e-1b9058b67214
md"""
Are the Diagrams exactly equivalent?
"""

# ╔═╡ 1cd5e23c-222a-44ee-90fd-1ea97e82954f
m_t ≈ m_o

# ╔═╡ bd9badb5-aace-4487-a6c3-63076efceb21
md"""
What is the trace distance of the matrices of the two circuits?
"""

# ╔═╡ 875a9b72-999b-40fd-b746-7fb315b190aa
#DynamicQuantumCircuits.QuantumInformation.equality(m_o, m_t)

# ╔═╡ Cell order:
# ╠═5d126c90-4711-11ee-0f12-e51f3cfa747f
# ╠═dfdd5c22-3981-46d0-9b2d-63f513b3c7a9
# ╟─e96a8b36-6330-439c-a856-dd8bee840b39
# ╟─2af6819a-0494-484f-9a8a-5d8efd0cf389
# ╟─38429f6b-8e57-40b7-a918-df3ac4fa4ea1
# ╟─f1871b30-0bd8-48d2-9e2d-9b8e1e82b6cd
# ╟─6dd31586-53cc-4315-a16d-28354a06d328
# ╟─18a83713-4cff-48e6-a9af-eeb221d65abf
# ╟─33bdf1a7-df06-422f-a817-20cf0e0763d3
# ╟─4ca57f9e-ef59-4f7c-8cf8-91c7d2f9aba5
# ╟─7622cc39-8e29-42b4-af93-60abf8fabb3a
# ╟─e3fa781e-ff02-4d9c-b314-049a92e92882
# ╟─01de9f1d-0307-4813-be15-df6f56cbeea5
# ╟─654e0826-5a4b-4b3b-bc36-cae10a479598
# ╟─0f800969-86a4-44c6-9fc2-021b8282ae8f
# ╟─8dc81bcb-d558-4ceb-9269-35ccd86c984d
# ╟─9d73b2aa-5b1a-4474-9264-655402599ecd
# ╠═637d5a6e-56ee-4149-a9cd-4a8784c53556
# ╟─ceac9e0d-5a86-4565-abfe-ba19d05433ca
# ╠═6b0087a2-e821-4195-808d-09d46b755380
# ╟─ecd5d804-0c51-44d7-ae0e-1b9058b67214
# ╠═1cd5e23c-222a-44ee-90fd-1ea97e82954f
# ╟─bd9badb5-aace-4487-a6c3-63076efceb21
# ╠═875a9b72-999b-40fd-b746-7fb315b190aa
