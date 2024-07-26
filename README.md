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

## CLI interface

* Change a specific parameter in the INCAR file: e.g., change the energy cutoff to 350 eV
```bash
vamp modify incar --par ENCUT --val 350
```

* Create a set of folders changing only one parameter: e.g., energy cutoff convergence testing
```bash
vamp convergence create --par ENCUT --val 300,350,400
```

* Or KSPACING
```bash
vamp convergence create --par KSPACING --val 0.5,0.4,0.3
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

## Parsing

### Atomic configurations

Read the POSCAR input file from VASP.

```julia
poscar_path = "path/to/POSCAR"

poscar = read_poscar(poscar_path)
```

One can also read the atomic configuration from an MD run from the XDATCAR file.

```julia

xdatcar_path = "path/to/XDATCAR"
xdatcar = read_xdatcar(xdatcar_path)

```

### DFT Eigenvalues

Here's an example of how to read the EIGENVAL file from a VASP calculation and extract the k-points, energy bands and occupancies:

```julia
eigenval_path = "path/to/EIGENVAL"
# Read the EIGENVAL file
kpoints, E_bands, occs = read_eigenval(eigenval_path)
```

### DFT Density of States (DOS)

To read the DOSCAR file and extract the density of states:

```julia
doscar_path = "path/to/DOSCAR"

# Read the DOSCAR file
dos, meta = read_doscar(doscar_path)
```
