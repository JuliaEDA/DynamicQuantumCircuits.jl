### A Pluto.jl notebook ###
# v0.19.38

#> [frontmatter]
#> title = "Quantum Circuit Equivalence Checking"
#> 
#>     [[frontmatter.author]]
#>     name = "Liam Hurwitz"

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
begin
  import Pkg

  #Pkg.activate(mktempdir()) /tmp/jl_3n9vVF
  Pkg.activate("/tmp/jl_3n9vVF")
  #Pkg.add(path="/home/liam/src/quantum-circuits/impl/DynamicQuantumCircuits", rev="feat/zx")
  Pkg.add("DataFrames")
  Pkg.add("Vega")
  Pkg.add(url="https://github.com/Roger-luo/Expronicon.jl")
  Pkg.add(url="https://github.com/JuliaCompilerPlugins/CompilerPluginTools.jl")
  Pkg.add(url="/home/liam/src/qc2/software/DynamicQuantumCircuits.jl")

  Pkg.add(url="https://github.com/QuantumBFS/YaoHIR.jl")
  Pkg.add(url="https://github.com/contra-bit/OpenQASM.jl.git", rev="feature/czgate")
  Pkg.add(url="https://github.com/QuantumBFS/YaoLocations.jl", rev="master")
  Pkg.add(url="https://github.com/QuantumBFS/Multigraphs.jl")
  #Pkg.add(url="https://github.com/contra-bit/ZXCalculus.jl", rev="feat/convert_to_zxwd
  Pkg.add(url="/home/liam/src/qc2/software/ZXCalculus.jl", rev="feature/plots")
  Pkg.add("PlutoUI")
  Pkg.add("ProfileVega")

  Pkg.add("BenchmarkPlots")
  Pkg.add("StatsPlots")


  # Extension Dependencies
  using DataFrames
  using Vega
  using OpenQASM
  # AST Circuit Transformtation
  using DynamicQuantumCircuits
  using OpenQASM
  using OpenQASM.Types


  # ZX Calculus Tools
  using ZXCalculus, ZXCalculus.ZX
  using YaoHIR, YaoLocations
  using YaoHIR.IntrinsicOperation
  using YaoHIR: BlockIR


  # Pluto Tools
  using PlutoUI

  # Benchmark Tools
  using BenchmarkTools

  # ZXW
  using ZXCalculus.ZXW:
    symbol_vertices,
    dagger,
    concat!,
    expval_circ!,
    push_gate!,
    stack_zxwd!,
    substitute_variables!


end

# ╔═╡ 81882f3e-9be9-4a15-9da2-6dbe71199e01
begin
  using BenchmarkPlots, StatsPlots
  suite = BenchmarkGroup()
  suite["equivalence"] = BenchmarkGroup(["operator, zxcalculus"])
  suite["equivalence"]["matrix"] = @benchmarkable verify_equivalence(static_quantum_circuit, dynamic_quantum_circuit, false)
  suite["equivalence"]["zx-matrix"] = @benchmarkable verify_equivalence(static_quantum_circuit, dynamic_quantum_circuit)
  suite["equivalence"]["zx"] = @benchmarkable verify_equivalence(static_quantum_circuit, dynamic_quantum_circuit)

  tune!(suite)
  results = run(suite)
  nothing
end

# ╔═╡ 13dd1496-1321-4323-83cc-6e4c6e3d54bc
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
	}
</style>
"""


# ╔═╡ d8de0d85-d0cf-4d65-87dc-d111538691e0
TableOfContents(title="📚 Table of Contents", indent=true, depth=4, aside=true)

# ╔═╡ 31304b6e-1db3-4899-a0fa-1ed7f0ffcae6
template_static = """
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q[3];
  creg c[2];
  h q[0];
  h q[1];
  """

# ╔═╡ f49d681f-4da1-4da1-b080-481e9320a710
template_dynamic = """
 OPENQASM 2.0;
 include "qelib1.inc";
 qreg q[2];
 creg c1[1];
 creg c2[1];
 h q[0];
 x q[1];
 """

# ╔═╡ b143ea23-0ef5-41dd-8110-9019f0bc9df5
struct TwoColumn{L,R}
  left::L
  right::R
end

# ╔═╡ 49b6ab02-19aa-4c91-a638-5f96ad200138
function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
  write(io, """<div style="display: flex;"<div style="flex: 50%">""")
  show(io, mime, OpenQASM.parse(tc.left))
  write(io, """</div><div style="flex: 50%;">""")
  Base.show(io, mime, plot(ZXDiagram(BlockIR(OpenQASM.parse(tc.right)))))
  write(io, """</div></div>""")
end

# ╔═╡ 2c7851f0-fc7e-43ec-9bf0-73b04094c627
function Base.show(io::IO, mime::MIME"text/html", zx::Union{ZXDiagram,ZXGraph})
  g = plot(zx)
  Base.show(io, mime, g)
end

# ╔═╡ ff3c29bf-16ba-4cfc-a6d1-124c06558eba
ZXDiagram(1)

# ╔═╡ 714bf9bb-739f-40cb-b40e-067645bf1e0b
begin
  @bind qc1 TextField(default=template_static)
  TwoColumn(qc1, ZXDiagram(BlockIR(OpenQASM.parse(qc1))))
end

# ╔═╡ c02f7f71-6143-48cb-914c-95aa1c17af35
begin
  @bind qc2 TextField(default=template_static)
  TwoColumn(qc1, ZXDiagram(BlockIR(OpenQASM.parse(qc1))))
end

# ╔═╡ 6a9cb29c-987c-43d1-9c75-330c3cca035b
begin

  @bind values PlutoUI.combine() do Child
    md"""
    ## Quantum Circuit Equivalence Checker

    T1 $(
    	Child(TextField((30, 30), template_static))
    ) T2 $(
    	Child(TextField((30, 30), template_dynamic))
    )

    Apply unitary reconstruction? $(Child(CheckBox(true)))
    Backend $(Child(Select(["zx" => "ZXCalculus Julia", "m" => "Matrix Julia", "mqt " => "Munic Quantum Toolkit", "tdd" => "Tensor Decision Network"])))
    """
  end
end

# ╔═╡ f3c60ce9-4f7b-44da-917e-c795a3f25909
@bind values1 PlutoUI.combine() do Child
  md"""
  # Hi there!

  I have $(
  	Child(Slider(1:10))
  ) dogs and $(
  	Child(Slider(5:100))
  ) cats.

  Would you like to see them? $(Child(CheckBox(true)))
  """
end

# ╔═╡ 8f8f8525-9ee1-4a34-8b58-9a6f1ae77859
begin
  static_quantum_circuit = values[1]
  dynamic_quantum_circuit = values[2]

  md"""#### Equivalence Check:  $t_1 == t_2 \leftarrow$ $(verify_equivalence(static_quantum_circuit, dynamic_quantum_circuit))
  #### Quantum Circuit Diagrams"""
end

# ╔═╡ 681b1495-e269-47d4-a00f-bd193905f640
md""" Equivalence Check:  $t_1 == t_2 \leftarrow$ $(verify_equivalence(static_quantum_circuit, dynamic_quantum_circuit))"""

# ╔═╡ 7f88edbb-0ce9-4d2f-a48e-282c70129905
t1 = OpenQASM.parse(static_quantum_circuit)

# ╔═╡ 9601c163-9227-4eaf-ab2b-14afab7e7a0d
t2 = OpenQASM.parse(dynamic_quantum_circuit)


# ╔═╡ 422b10c7-7546-4c3c-a073-e276830cdefb


# ╔═╡ 53bfaff5-3657-4f0f-9c2f-6b1285fc3557
md"""**Quantum Circuit $T_1$**"""

# ╔═╡ 38429f6b-8e57-40b7-a918-df3ac4fa4ea1
Operator.graphical_circuit(static_quantum_circuit)

# ╔═╡ 1783588a-52d1-4426-8380-225604d24fcc
md"""**Quantum Circuit $T_2$**"""

# ╔═╡ b2b4444b-c720-4204-b761-92dd8e982cd1
begin
  Operator.graphical_circuit(dynamic_quantum_circuit)
end

# ╔═╡ 5b2588ba-d69d-4f3b-bba6-c7fdef38dcec

md"""### Unitary Reconstruction
Resets have been removed and replace with new qubits and measuremnts have are deferred"""


# ╔═╡ 2a389727-00b3-4fca-9873-987698a833ec
begin
  if values[3]
    transpiled_circuit = unitary_reconstruction(dynamic_quantum_circuit)
  end
end

# ╔═╡ 9903c956-48ff-4289-81c0-5ba35806e186
md"""
#### ZXDiagram of the static circuit
"""

# ╔═╡ f1871b30-0bd8-48d2-9e2d-9b8e1e82b6cd
begin
  bir_original = BlockIR(values[1])
  zxd_original = ZXDiagram(bir_original)
end

# ╔═╡ 0bce2a32-7f9e-466d-930b-4cc6aaaad947
md"""
#### ZXDiagram of the reconstructed unitary circuit circuit
"""

# ╔═╡ e3fa781e-ff02-4d9c-b314-049a92e92882
begin
  bir_transpiled = BlockIR(transpiled_circuit)
  zxd_transpiled = ZXDiagram(bir_transpiled)
  #pushfirst_gate!(zxd_transpiled, Val{:SWAP}(), [1, 2])
end

# ╔═╡ 9d73b2aa-5b1a-4474-9264-655402599ecd
md"""
## ZX Calculus Equivalence Checking
Using an equivalence checking mitter

#### Proving equivalence of quantum circuits
##### Input: 
Quantum Circuits $G$, $G′$
##### Output: 
TRUE if $G$ and $G$ ′ are equivalent or FALSE otherwise
#### Steps
1. Convert $D$ ← ZX-diagram of $G$
2. Append $D' = M \rightarrow D\dagger_{r} \cdot D_{r}$ ← ZX-diagram of $G′$
3. Convert $M$ to graph-like form
4. Apply Full Reduction into a ZXGraph
6. if $M$ consists only of wires result = **True** otherwise **False**

$D_{r}$
"""

# ╔═╡ 0699d680-f23d-4475-9941-2d91111c9c2a
reduced_o = full_reduction(zxd_original)

# ╔═╡ e0327f90-8618-41b7-a70d-45e9bf6264dd
md"""$D\dagger_{r}$"""

# ╔═╡ e15f3e58-3235-4130-b1d4-77667e866927
reduced_t = full_reduction(zxd_transpiled)

# ╔═╡ 404b4d7a-2057-4a6e-8f6b-2ef04e87235c
md"""$M \rightarrow D\dagger_{r} \cdot D_{r}$"""

# ╔═╡ 76e26794-3faa-4b0b-b80c-5dcd7ffa6fdf
M = concat!(zxd_original, zxd_transpiled)

# ╔═╡ 9d628494-0d36-4709-9216-abfce1239496
md"""#### Equivalence Check:  
Result: $t_1 == t_2 \leftarrow$ $(contains_only_bare_wires(M))"""


# ╔═╡ 90acc0db-5e53-4c6a-9e60-4a0a861a8005
md"""
## Operator Based Equivalence Checking
Operator based equivalence checking allows us to measure the closeness of two ZXDiagrams

#### Approach 1: 
Using Qiskit to obtain the operator
"""

# ╔═╡ 640dfb35-331e-4406-917a-1ab5adb6843c
verify_equality(zxd_original, zxd_transpiled)

# ╔═╡ 816d361e-31de-4207-a9a1-2335b1ed3ae8
md"""
#### Approach 2: 
1. Using ZXWDigrams to obtain the matrix by finding the optimal tensor contraction.
2. Obtain trace distance of the matrices of the two circuits. So see if they are close

##### Trace Distance of $t_1$ and $t_2$:
"""

# ╔═╡ 5a343274-f855-48e8-9a8e-8182c027d7a0
begin
  function zxd_matrix()
    m_original = Matrix(convert_to_zxwd(bir_original))
    m_transpiled = Matrix(convert_to_zxwd(bir_transpiled))
    qc_trace_distance(m_original, m_transpiled)
  end
  zxd_matrix()

end

# ╔═╡ ba3798c7-8447-40ff-80fd-e382c2ed0c36
md"""
## Benchmark
Benchmark of the *ZX equivalence mitter* 
"""


# ╔═╡ abf32aa2-8746-44f1-a5e1-c17c7b030887
t = @benchmark verify_equivalence(static_quantum_circuit, dynamic_quantum_circuit)

# ╔═╡ 7e4259c6-956b-4da7-b26a-2587eb2fd8ff
md"""
#### Benchmark comparing the 3 different approaches
- The y axis is $log_{10}$
- The sample sized for each benchmark is $1000$
"""

# ╔═╡ d7faa585-2501-4d5f-8dc1-54deb7d9c327
StatsPlots.plot(results[:equivalence], yaxis=:log10)

# ╔═╡ 2d92c224-4bf4-43d8-afff-57eb61611559
results[:equivalence]

# ╔═╡ fce71579-1954-4fed-a186-086aba263006
zxwd_original = ZXWDiagram(bir_original)

# ╔═╡ 69324f8c-3306-48a7-ae93-0bc2c4765a5c


# ╔═╡ 01552cb4-6026-4808-9df8-98e1f34f6adb
zxwd_transpiled = ZXWDiagram(bir_transpiled)

# ╔═╡ 1d330f13-59ca-4d7c-852e-4f4f6643350f
zxwd_dagger = dagger(bir_transpiled)

# ╔═╡ 0d6a984b-3dc6-4add-bc80-921ca0886929
zxwd = concat!(zxwd_transpiled, zxwd_dagger)

# ╔═╡ 4d93df88-a276-44a8-bd1a-178b38bd4e76
deri_rule = CalcRule(:diff, :p)

# ╔═╡ f143dd9f-10a6-4926-a625-271bc9eef95f
int_rule = CalcRule(:int, :a)


# ╔═╡ a5ac74b2-9a56-4b30-919c-b980afec1c53
begin
  exp_zxwd = expval_circ!(copy(zxwd), "ZZ")

  exp_pluspihf = substitute_variables!(copy(exp_zxwd), Dict(:a => a, :b => b + 1 / 2))
  exp_mnuspihf = substitute_variables!(copy(exp_zxwd), Dict(:a => a, :b => b - 1 / 2))

  # should be around -1.8465
  gradient_parameter_shift =
    real(π / 2 * (Matrix(exp_pluspihf)[1, 1] - Matrix(exp_mnuspihf)[1, 1]))


  matches = match(CalcRule(:diff, :b), exp_zxwd)
  diff_zxwd = rewrite!(CalcRule(:diff, :b), exp_zxwd, matches)

  diff_zxwd = substitute_variables!(diff_zxwd, Dict(:a => a, :b => b))

  diff_mtx = Matrix(diff_zxwd)
  # our parameter is in unit of pi
  # during derivation, dummy variable will have extra factor of pi
  gradient = real(diff_mtx[1, 1]) * π

end

# ╔═╡ Cell order:
# ╟─13dd1496-1321-4323-83cc-6e4c6e3d54bc
# ╠═5d126c90-4711-11ee-0f12-e51f3cfa747f
# ╠═d8de0d85-d0cf-4d65-87dc-d111538691e0
# ╠═31304b6e-1db3-4899-a0fa-1ed7f0ffcae6
# ╠═f49d681f-4da1-4da1-b080-481e9320a710
# ╠═b143ea23-0ef5-41dd-8110-9019f0bc9df5
# ╠═2c7851f0-fc7e-43ec-9bf0-73b04094c627
# ╠═49b6ab02-19aa-4c91-a638-5f96ad200138
# ╠═ff3c29bf-16ba-4cfc-a6d1-124c06558eba
# ╠═714bf9bb-739f-40cb-b40e-067645bf1e0b
# ╠═c02f7f71-6143-48cb-914c-95aa1c17af35
# ╠═6a9cb29c-987c-43d1-9c75-330c3cca035b
# ╠═f3c60ce9-4f7b-44da-917e-c795a3f25909
# ╟─8f8f8525-9ee1-4a34-8b58-9a6f1ae77859
# ╟─681b1495-e269-47d4-a00f-bd193905f640
# ╟─7f88edbb-0ce9-4d2f-a48e-282c70129905
# ╟─9601c163-9227-4eaf-ab2b-14afab7e7a0d
# ╟─422b10c7-7546-4c3c-a073-e276830cdefb
# ╟─53bfaff5-3657-4f0f-9c2f-6b1285fc3557
# ╟─38429f6b-8e57-40b7-a918-df3ac4fa4ea1
# ╟─1783588a-52d1-4426-8380-225604d24fcc
# ╟─b2b4444b-c720-4204-b761-92dd8e982cd1
# ╟─5b2588ba-d69d-4f3b-bba6-c7fdef38dcec
# ╟─2a389727-00b3-4fca-9873-987698a833ec
# ╠═9903c956-48ff-4289-81c0-5ba35806e186
# ╠═f1871b30-0bd8-48d2-9e2d-9b8e1e82b6cd
# ╟─0bce2a32-7f9e-466d-930b-4cc6aaaad947
# ╠═e3fa781e-ff02-4d9c-b314-049a92e92882
# ╟─9d73b2aa-5b1a-4474-9264-655402599ecd
# ╟─0699d680-f23d-4475-9941-2d91111c9c2a
# ╟─e0327f90-8618-41b7-a70d-45e9bf6264dd
# ╠═e15f3e58-3235-4130-b1d4-77667e866927
# ╟─404b4d7a-2057-4a6e-8f6b-2ef04e87235c
# ╟─76e26794-3faa-4b0b-b80c-5dcd7ffa6fdf
# ╟─9d628494-0d36-4709-9216-abfce1239496
# ╟─90acc0db-5e53-4c6a-9e60-4a0a861a8005
# ╠═640dfb35-331e-4406-917a-1ab5adb6843c
# ╟─816d361e-31de-4207-a9a1-2335b1ed3ae8
# ╟─5a343274-f855-48e8-9a8e-8182c027d7a0
# ╟─ba3798c7-8447-40ff-80fd-e382c2ed0c36
# ╠═abf32aa2-8746-44f1-a5e1-c17c7b030887
# ╠═81882f3e-9be9-4a15-9da2-6dbe71199e01
# ╟─7e4259c6-956b-4da7-b26a-2587eb2fd8ff
# ╠═d7faa585-2501-4d5f-8dc1-54deb7d9c327
# ╟─2d92c224-4bf4-43d8-afff-57eb61611559
# ╠═fce71579-1954-4fed-a186-086aba263006
# ╠═69324f8c-3306-48a7-ae93-0bc2c4765a5c
# ╠═01552cb4-6026-4808-9df8-98e1f34f6adb
# ╠═1d330f13-59ca-4d7c-852e-4f4f6643350f
# ╠═0d6a984b-3dc6-4add-bc80-921ca0886929
# ╠═4d93df88-a276-44a8-bd1a-178b38bd4e76
# ╠═f143dd9f-10a6-4926-a625-271bc9eef95f
# ╠═a5ac74b2-9a56-4b30-919c-b980afec1c53
