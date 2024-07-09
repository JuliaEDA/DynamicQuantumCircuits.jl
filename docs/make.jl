cd(@__DIR__)
using Documenter, Literate
using DynamicQuantumCircuits


import Documenter
using Literate

# literate the tutorial
 # convert tutorial/examples to markdown
Literate.markdown(
    joinpath(@__DIR__, "src", "tutorial.jl"), joinpath(@__DIR__, "src");
    credit = false
)

# Which markdown files to compile to HTML
# (which is also the sidebar and the table
# of contents for your documentation)
 pages = [
 "Introduction" => "index.md",
 "Tutorial" => "tutorial.md",
 "API" => "api.md",
 "Devlopment" => "internal.md"
 ]
 # compile to HTML:

makedocs(
    sitename = "DynamicQuantumCircuits",
    format = Documenter.HTML(),
    modules = [DynamicQuantumCircuits]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "https://github.com/JuliaEDA/DynamicQuantumCircuits.jl"
)
