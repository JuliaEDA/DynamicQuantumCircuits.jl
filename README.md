# DynamicQuantumCircuits

[![Build Status](https://github.com/JuliaEDA/DynamicQuantumCircuits.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaEDA/DynamicQuantumCircuits.jl/actions/workflows/CI.yml?query=branch%3Amain)

DynamicQuantumCircuits.jl is a Julia package that addresses the limitations of Noisy Intermediate-Scale Quantum (NISQ) hardware by reducing qubit count. In the NISQ era, the major challenge is efficiently mapping quantum algorithms to these noisy computers. The solution lies in analyzing whether quantum algorithms can be mapped to real hardware with fewer qubits, which was not possible until the introduction of Dynamic Quantum Circuits (DQC).

DynamicQuantumCircuits is a package for:

- [ ] **Optimizing** the qubit count of a static quantum circuit by converting it into a dynamic quantum circuit.
- [X] Applying **unitary_reconstruction** to to obtain a static quantum circuit from a dynamic quantum circuit.
- [X] **Verification** of the equivalence between the DQC and the original static quantum circuit (SQC).

Static Quantum Circuits (SQC) are limited by a restricted number of qubits, shallow coherence, and low fidelity. In contrast, Dynamic Quantum Circuits (DQC) offer several advantages:

- Minimized qubit count by recycling qubits.
- Improved fidelity and more control.

The goal of this package is to provide a tool for researchers and developers working on quantum computing to optimize qubit usage and improve the performance of quantum algorithms on NISQ hardware.

To get started, you can install the package by running `import Pkg; Pkg.add("DynamicQuantumCircuits")`. The full documentation is available online and can also be built locally by running the `docs/make.jl` file.
