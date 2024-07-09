### A Pluto.jl notebook ###
# v0.19.37

using Markdown
using InteractiveUtils

# ╔═╡ 94819fed-1f0f-40c4-bddb-30a012d2a532
begin
  import Pkg
  Pkg.add(url="https://github.com/Roger-luo/Expronicon.jl")
  Pkg.add(url="https://github.com/JuliaCompilerPlugins/CompilerPluginTools.jl")
  Pkg.add(url="https://github.com/QuantumBFS/YaoHIR.jl", rev="master")
  Pkg.add(url="https://github.com/QuantumBFS/YaoLocations.jl", rev="master")
  Pkg.add(url="/home/liam/src/qc2/software/ZXCalculus.jl")
  #	Pkg.add(url="/home/liam/src/quantum-circuits/software/YaoPlots.jl")
end

# ╔═╡ 7f5160d4-5974-11ee-2f41-c14a2ff15747
begin
  using ZXCalculus
  using YaoHIR, YaoLocations
  using YaoHIR.IntrinsicOperation
  using CompilerPluginTools

end

# ╔═╡ de267d13-9da7-44ef-a674-7ea8f7c0b71e
md"""
# Traditional Circuit
"""

# ╔═╡ 08b28305-020f-4557-a0d5-67c9b8820f24
begin
  chain_t = Chain()
  push_gate!(chain_t, Val(:H), 1)
  push_gate!(chain_t, Val(:H), 2)
  push_gate!(chain_t, Val(:X), 3)
  push_gate!(chain_t, Val(:H), 3)
  push_gate!(chain_t, Val(:CNOT), 1, 3)
  push_gate!(chain_t, Val(:X), 1)
  push_gate!(chain_t, Val(:CNOT), 2, 3)
  push_gate!(chain_t, Val(:H), 2)
end

# ╔═╡ d5c2c610-93ef-4f17-b0cb-feb54df783b7
begin
  ir_t = @make_ircode begin end
  bir_t = BlockIR(ir_t, 4, chain_t)
  zxd_t = convert_to_zxd(bir_t)
end

# ╔═╡ f1fe994e-b502-442c-a4e6-41949c7dabab
zxg_t = ZXGraph(zxd_t)

# ╔═╡ 5a5da98a-a41f-422e-af75-84d3d8986f1d
plot(zxd_t; scale=3)

# ╔═╡ fecd4ace-c768-4199-9bb7-a36e023d4d30
plot(zxg_t)

# ╔═╡ c60aae35-c5bb-4be2-b459-bbcd7ca65723
Matrix(zxg_t)

# ╔═╡ Cell order:
# ╠═94819fed-1f0f-40c4-bddb-30a012d2a532
# ╠═7f5160d4-5974-11ee-2f41-c14a2ff15747
# ╟─de267d13-9da7-44ef-a674-7ea8f7c0b71e
# ╠═08b28305-020f-4557-a0d5-67c9b8820f24
# ╠═d5c2c610-93ef-4f17-b0cb-feb54df783b7
# ╠═f1fe994e-b502-442c-a4e6-41949c7dabab
# ╠═5a5da98a-a41f-422e-af75-84d3d8986f1d
# ╠═fecd4ace-c768-4199-9bb7-a36e023d4d30
# ╠═c60aae35-c5bb-4be2-b459-bbcd7ca65723
