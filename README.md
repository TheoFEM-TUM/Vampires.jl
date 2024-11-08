<p align="center">
  <img width="460" height="460" src="https://github.com/user-attachments/assets/b0ec8dd0-b5eb-4acc-892a-dc184e10f8c2">
</p>

# VASP Analysis for Materials Properties In Realistic Energy Surfaces
## A Collection of Toolkits for VASP Postprocessing in Julia, currently named:

`Vampires.jl` is a Julia package designed to streamline the analysis of VASP (Vienna Ab initio Simulation Package) output files. It provides a comprehensive suite of tools for parsing and visualizing data from VASP calculations, including electronic structure, band structure, density of states, and more. With a focus on ease of use and performance, `Vampires.jl` leverages Julia's capabilities to handle large datasets efficiently.

## How to install `Vampires.jl` in Julia

* First, you need to install Julia itself from the [Julia homepage](https://julialang.org/downloads/)
* Next, clone the git repository to your computer. For this, you need to be added as developer by one of the admins. The `git_clone_link` can be found by clicking the green `<> Code` box in the top right corner on the repos main page.
```bash
git clone <git_clone_link>
```
* Then, run the install packages script form the main package folder (assuming your `.bashrc` file is located at `$HOME`).
```bash
julia vampires_install.jl && source $HOME/.bashrc
```
You can then call the `Vampires` CLI interface using `vamp`.

## Documentation

Since `Vampires.jl` is not (yet) a registered Julia package, the documentation is not publicly hosted. Nevertheless, you can build and open it yourself in firefox by calling

```bash
julia vampires_docs.jl
```

For the CLI, you can access detailed documentation directly from the command line using the `--help` (or `-h`) flag. You don't need to build the documentation for this.
For a general overview of all available tasks, enter:
```bash
vamp --help
```
To list all available subtasks for a specific `task`, use:
```bash
vamp --help <task>
```
Finally, to see detailed documentation for a particular subtask, enter:
```bash
vamp --help <task> <subtask>
```

## Example Usage

Below are several examples demonstrating how to use `Vampires.jl` in practice. Each command begins with the main executable (`vamp` by default), followed by two positional arguments: `task` and `subtask` (the latter is sometimes optional). The `task` typically represents a category or file type (e.g., `incar`, `outcar`), while the `subtask` is an action verb (e.g., `make`, `read`, `plot`) describing the operation to be performed. After these positional arguments, various keyword arguments can be added to specify the exact operation the user wants to perform.

Firstly, `Vampires.jl` supports various ways to modify an `INCAR` file. To create a new incar file with tags `ENCUT` and `ISMEAR`
```bash
vamp incar make --par ENCUT,ISMEAR
```
If the `val` argument is not provided, default values are used. A value can be modified with
```bash
vamp incar set --par ENCUT --val 400
```
Furthermore, `Vampires.jl` enables users to easily streamline workflows that would otherwise be tedious, such as convergence testing. For instance, generating the folder structure for a convergence test of the cut-off energy can be done with a simple command like:
```bash
vamp convergence make -par ENCUT --val 300,350,400
```

This command creates three subfolders and copies all necessary input files into each one. Next, a bash script is needed to run VASP in each subfolder. The `-r` flag (recursive mode) instructs `Vampires.jl` to execute the specified task within each subfolder. Recursive mode is supported for various tasks, making it ideal for methods that require batch execution, like convergence tests.
```bash
vamp -r run_script make --vasp_exe vasp_std
```
Finally, once the calculations are complete, we can plot the results—such as the total energy versus the cut-off energy—providing a clear visualization of the convergence behavior.
```bash
vamp -r outcar plot --par TOTEN --o total_energy_vs_encut.png
```

For more detailed information, please refer to the official documentation.

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
