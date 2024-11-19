# Install `Vampires.jl`
## How to install `Vampires.jl` in Julia

* First, you need to install Julia itself from the [Julia homepage](https://julialang.org/downloads/)
* Next, clone the git repository to your computer
* Then, run the install packages script form the main package folder
```bash
path=<path_to_your_bashrc> && julia vampires_install.jl --bashrc $path && source $path
```
You can then call the `Vampires` CLI interface using `vamp`.

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

## Setting up a Vampires module on an HPC system

In order to have access to `Vampires.jl` commands in, e.g., a slurm job script, it is necessary to set up a module that can be loaded within the script. To this end, you want to create a module for example with the following lua script.

```lua
help([==[

Description
===========

The Vampires.jl package to analyze VASP data and optimize VASP workflows.
]==])

whatis("Name: Vampires")
whatis("Version: VERSION")

conflict("Vampires")

depends_on(<julia_module>, <other_deps>)

prepend_path("PATH", <path_to_vampires>)

set_shell_function("vamp_install", "julia <path_to_vampires/vampires_install.jl> --add_path no")
```

Before being able to use `Vampires.jl` you want to once envoke `vamp_install` to install all necessary dependencies.