# List of Available Tasks

```
convergence
    make: creates the folder structure where the specified parameter is changed in the different subdirectories
    read: reads a specific output (e.g., energy) from a convergence test
    plot: plots a specific output (e.g., TOTEN) vs folder seed (e.g., ENCUT)
```

```
doscar
    read: read-in the doscar file
    plot: plot the dos from the doscar file
```

```

eigenval:
    read: read the data from the eigenval file.
    plot: plot the bandstructure from the eigenval file.
```

```

h5:
    read: call the read task for `file` and create a plot.
```

```
incar
    set/add: changes or adds a parameter _par_ to a given value _value_ or adds a block to the incar
    rm: remove a certain tag or block from the INCAR file.
    read: read the value of a certain INCAR tag and print it
    make: create an INCAR file with certain tags or blocks in it
    whatis: return the default comment for an INCAR tag.
```

```
kpoints
    make: generate a kpoint file for a certain grid size or kspacing, respectively.
```

```
supercell
    make: create a supercell POSCAR file from an existing POSCAR file
    sample: create folders that each contains one snapshot from an XDATCAR file and other VASP input files
```

```
nscf
    make: generate the folder structure for a scf->nscf calculation
```

```
outcar
    read: read a certain value from the outcar file
    plot: plot a series of values from an OUTCAR file. If recursive, plot one value from an OUTCAR file in multiple folders.
```

```

<task>:
    plot: call the read task for `file` and create a plot.
```

```
poscar
    read: read the POSCAR file
```

```
### recursive wrapper for all tasks:
any_task
    any_subtask: if the option `-r` is specified, the subtask will run in every subfolder of `./`

```

```
runscript
    make: creates a bash script that runs vasp in a specific folder
input
    cp: copy all VASP input files to a new folder
job
    make: creates a job script for the given parameters.
    submit: submit all job files
    status: show the status of all active jobs
    cancel: cancel a given job
```

```
settings
    set: set a new setting in the settings file
    rm: remove a setting from the settings file
    read: read a setting from the settings file
```

```
Processes and outputs data from a `read` task based on a specified method, handling recursive operations, broadcasting, and error reporting.

# Parameters
- `out`: A NamedTuple that associates a parameter `key` with an AbstractArray of values.
- `args`: A dictionary of arguments with the following expected keys:
  - `"o"`: The output file path where results will be written.
  - `"reduce"`: A string specifying the processing method. If the last character is `"."`, broadcasting is applied to the method.
  - `"r"`: A boolean flag indicating whether to apply recursive processing.
  - `"v"`: A boolean flag to enable verbose output.
```

```
"""
    @run_task(task, subtask, args...)
    @run_task_recursive(task, subtask, args...)

This macro provides a convenient way to call any `run_task` (or `run_task_recursive`) method without having to explicitly convert `task` and `subtask` into Val-types.
Args can either be a dictionary or a set of `key = value` pairs.

# Arguments
- `task::Symbol`: The task name (e.g., incar).
- `subtask::Symbol`: The subtask name (e.g., `set`).
- `args`: A set of key-value pairs passed as arguments (e.g., `key1 = value1`) or a dictionary.

# Returns
- A quoted expression that, when evaluated, will call the `run_task` function with the `task`, `subtask`, and arguments packaged into a dictionary.

# Example
```julia
# Example 1: Call the `incar set` task with arguments
@run_task incar set par = ENCUT val = 250

# Example 2: Call the `kpoints make` task with a dictionary that contains arguments
args = get_default_args()
@run_task kpoints make args

# Example 3: Call the `runscript make` recursively.
@run_task_recursive runscript make
```
```

```
w90_hr
    read: read the W90 Hamiltonian from the *_hr.dat file
    test: test the accuracy of a W90 model versus DFT
w90
    set: set parameters in the INCAR file that are specific to W90
w90_nscf
    make: create the folder structure for a NSCF calculation with W90
```

```

xdatcar:
    read: read the atomic configurations from the XDATCAR file.
    merge: merge multiple XDATCAR into one single file.
```

