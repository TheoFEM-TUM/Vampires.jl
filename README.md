<p align="center">
  <img width="460" height="460" src="https://github.com/user-attachments/assets/b0ec8dd0-b5eb-4acc-892a-dc184e10f8c2">
</p>

# VASP Analysis for Materials Properties In Realistic Energy Surfaces
## A Collection of Toolkits for VASP Postprocessing in Julia, currently named:

`Vampires.jl` is a Julia package designed to streamline the analysis of VASP (Vienna Ab initio Simulation Package) output files. It provides a comprehensive suite of tools for parsing and visualizing data from VASP calculations, including electronic structure, band structure, density of states, and more. With a focus on ease of use and performance, `Vampires.jl` leverages Julia's capabilities to handle large datasets efficiently.

## How to install `Vampires.jl` in Julia

* First, you need to install Julia itself from the [Julia homepage](https://julialang.org/downloads/)
* Next, clone the git repository to your computer
* Then, run the install packages script form the main package folder
```bash
path=<path_to_your_bashrc> && julia vampires_install.jl --bashrc $path && source $path
```
You can then call the `Vampires` CLI interface using `vamp`.

## Documentation

Since `Vampires.jl` is not (yet) a registered Julia package, the documentation is not publicly hosted. Nevertheless, you can build and open it yourself in firefox by calling

```bash
julia vampires_docs.jl
```

## Using `Vampires.jl` in Python

Install `PyJulia` package

```bash
pip install julia
```

Then you can import `Vampires.jl` into Python if it is installed in Julia

```Python
import julia
from julia import Julia
Julia(compiled_modules=False)

from julia import Vampires as vamp

vamp.SOMEFUNCTION ...
```
