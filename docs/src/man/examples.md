# Examples
## Using `Vampires.jl` in Julia

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
