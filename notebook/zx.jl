### A Pluto.jl notebook ###
# v0.19.43

using Markdown
using InteractiveUtils

# ╔═╡ e8fbaeac-515b-11ee-19f8-07c1cc24530a
begin
	using ZXCalculus
	
end

# ╔═╡ 11012be1-3af8-4c8b-a250-ae0573b3c1b1
zxd = ZXDiagram(4)

# ╔═╡ 7474d8a5-9573-445c-9979-e487790f1a47


# ╔═╡ 2f0e0462-9b2f-4b78-b655-7f064db5f0ac
push_gate!(zxd, Val{:Z}(), 1, 3//2)

# ╔═╡ 9d165359-8025-4570-bf10-51ae2857b0f8
push_gate!(zxd, Val{:Z}(), 1, 3//2)

# ╔═╡ 3a65b50e-3a4d-418b-ae00-cc62735dc7ec
circuit = convert_to_chain(zxd)

# ╔═╡ 67019f96-a5ef-4ab8-ab4f-245777bce3c8
vizcircuit(circuit)

# ╔═╡ 2b249177-b449-498b-814b-98fa7c4f9a58
plot(zxd[; "straight"])

# ╔═╡ 8643731e-36ab-417d-9c4a-e3348424d12f
zxd_easy = simplify!(r, zxd)

# ╔═╡ 93459ccf-0789-4cb0-b04b-7e167929a491
begin
	zxD_1 = ZXDiagram(2); push_gate!(zxd, Val{:CNOT}(), 2, 1);
	zxg = ZXGraph(zxD_1)
end

# ╔═╡ 17f4e3e0-ee5e-4e9e-827b-f4de8f671a58
begin
	zxg = ZXGraph(zxd)
	simplify!(Rule{:lc}(), zxg)
	simplify!(Rule{:p1}(), zxg)
	replace!(Rule{:pab}(), zxg)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ZXCalculus = "3525faa3-032d-4235-a8d4-8c2939a218dd"

[compat]
ZXCalculus = "~0.6.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.0-beta2"
manifest_format = "2.0"
project_hash = "f974462b4d32ca1856433719a3f96820e031306d"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BatchedRoutines]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "441db9f0399bcfb4eeb8b891a6b03f7acc5dc731"
uuid = "a9ab73d0-e05c-5df1-8fde-d6a4645b8d8e"
version = "0.2.2"

[[deps.BetterExp]]
git-tree-sha1 = "dd3448f3d5b2664db7eceeec5f744535ce6e759b"
uuid = "7cffe744-45fd-4178-b173-cf893948b8b7"
version = "0.1.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "71acdbf594aab5bbb2cec89b208c41b4c411e49f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.24.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "b1c55339b7c6c350ee89f2c1604299660525b248"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.15.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Expronicon]]
deps = ["MLStyle"]
git-tree-sha1 = "35141514242193e3e820d90007f973bf35bf5da0"
uuid = "6b7a57c9-7cc1-4fdf-b7f5-e857abae3636"
version = "0.10.10"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ebd18c326fa6cee1efb7da9a3b45cf69da2ed4d9"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.11.2"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.Multigraphs]]
deps = ["Graphs", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "055a7c49a626e17a8c99bcaaf472d0de60848929"
uuid = "7ebac608-6c66-46e6-9856-b5f43e107bac"
version = "0.3.0"

[[deps.OMEinsum]]
deps = ["AbstractTrees", "BatchedRoutines", "ChainRulesCore", "Combinatorics", "LinearAlgebra", "MacroTools", "OMEinsumContractionOrders", "Test", "TupleTools"]
git-tree-sha1 = "3b7f8f3ffb63e3c7fd0d9b364862a2e35f70478e"
uuid = "ebe7aa44-baf0-506c-a96f-8464559b3922"
version = "0.7.6"

    [deps.OMEinsum.extensions]
    CUDAExt = "CUDA"

    [deps.OMEinsum.weakdeps]
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"

[[deps.OMEinsumContractionOrders]]
deps = ["AbstractTrees", "BetterExp", "JSON", "SparseArrays", "Suppressor"]
git-tree-sha1 = "b0cba9f4a6f021a63b066f0bb29a6fd63c93be44"
uuid = "6f22d1fd-8eed-4bb7-9776-e7d684900715"
version = "0.8.3"

    [deps.OMEinsumContractionOrders.extensions]
    KaHyParExt = ["KaHyPar"]

    [deps.OMEinsumContractionOrders.weakdeps]
    KaHyPar = "2a6221f6-aa48-11e9-3542-2d9e0ef01880"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "eeafab08ae20c62c44c8399ccb9354a04b80db50"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.7"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.6.0+0"

[[deps.Suppressor]]
deps = ["Logging"]
git-tree-sha1 = "9143c41bd539a8885c79728b9dedb0ce47dc9819"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.7"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TupleTools]]
git-tree-sha1 = "41d61b1c545b06279871ef1a4b5fcb2cac2191cd"
uuid = "9d95972d-f1c8-5527-a6e0-b4b365fa01f6"
version = "1.5.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.YaoHIR]]
deps = ["Expronicon", "MLStyle", "YaoLocations"]
git-tree-sha1 = "b1e17fb84f1b322bef9910c942c1c9beb3e919ef"
uuid = "6769671a-fce8-4286-b3f7-6099e1b1298a"
version = "0.2.3"

    [deps.YaoHIR.extensions]
    YaoHIRExt = ["OpenQASM"]

    [deps.YaoHIR.weakdeps]
    OpenQASM = "a8821629-a4c0-4df7-9e00-12969ff383a7"

[[deps.YaoLocations]]
git-tree-sha1 = "c90c42c8668c9096deb0c861822f0f8f80cbdc68"
uuid = "66df03fb-d475-48f7-b449-3d9064bf085b"
version = "0.1.6"

[[deps.ZXCalculus]]
deps = ["Expronicon", "Graphs", "LinearAlgebra", "MLStyle", "Multigraphs", "OMEinsum", "SparseArrays", "YaoHIR", "YaoLocations"]
git-tree-sha1 = "9110975b06644a0844c98e13944c00af26087bf4"
uuid = "3525faa3-032d-4235-a8d4-8c2939a218dd"
version = "0.6.0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"
"""

# ╔═╡ Cell order:
# ╠═e8fbaeac-515b-11ee-19f8-07c1cc24530a
# ╠═11012be1-3af8-4c8b-a250-ae0573b3c1b1
# ╠═7474d8a5-9573-445c-9979-e487790f1a47
# ╠═2f0e0462-9b2f-4b78-b655-7f064db5f0ac
# ╠═9d165359-8025-4570-bf10-51ae2857b0f8
# ╠═3a65b50e-3a4d-418b-ae00-cc62735dc7ec
# ╠═67019f96-a5ef-4ab8-ab4f-245777bce3c8
# ╠═93459ccf-0789-4cb0-b04b-7e167929a491
# ╠═2b249177-b449-498b-814b-98fa7c4f9a58
# ╠═8643731e-36ab-417d-9c4a-e3348424d12f
# ╠═17f4e3e0-ee5e-4e9e-827b-f4de8f671a58
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
