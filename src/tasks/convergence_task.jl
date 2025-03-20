"""
list of available tasks:

convergence
    make: creates the folder structure where the specified parameter is changed in the different subdirectories
    read: reads a specific output (e.g., energy) from a convergence test
    plot: plots a specific output (e.g., TOTEN) vs folder seed (e.g., ENCUT)
"""
# TODO: unify this with time series and ionic relaxation


"""
# CLI Commands to do convergence testing

Available commands:
* `vamp convergence make`: Create the folder structure for convergence testing.
"""
run_task(::Type{Val{:convergence}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] convergence make --par <parameter> --val <range> [--p <path>] [--method <method>]

Create subdirectories for convergence tests, each with varying values for the specified parameter.

# Arguments
- `par`: The parameter for which the convergence test will be run (e.g., `ENCUT`, `kgrid`, etc.).
- `val`: A comma-separated range of values to use for the parameter (e.g., `400,500,600`).
- `p`: The path where subdirectories for the convergence tests will be created (optional; defaults to the current directory).
- `method`: The method for generating the k-grid, only relevant for k-grid convergence.

# Examples
```bash
# Example 1: Create subdirectories for ENCUT convergence with values 400, 500, and 600.
vamp convergence make --par ENCUT --val 400,500,600

# Example 2: Create subdirectories for k-grid convergence with values 2x2x2, 3x3x3, and 4x4x4 using a Monkhorst-Pack grid.
vamp convergence make --par kgrid --val 2,3,4 --method mp

# Example 3: Generate subdirectories for a logarithmic convergence test for LREAL with values True and False in a specified folder.
vamp convergence make --par LREAL --val True,False --path lreal_tests
```
"""
function run_task(::Type{Val{:convergence}}, ::Type{Val{:make}}, args)
    param = args["par"]
    param_range = split(args["val"], ",")
    path = args["p"]
    include_files = split_line(args["include"], char=',')
    convergence_create_subdirectories(param, param_range; path=path, method=args["method"], incar=args["incar"], include_files=include_files, kpoints=args["kpoints"], poscar=args["poscar"], potcar=args["potcar"])
    return nothing
end

"""
    vamp [-r] outcar read --par <parameter> [--outcar <file>] [--p <path>] [--o <output>]

Read specific data from the OUTCAR file and optionally save the data to an HDF5 file.
    - Same as `outcar read` but naming is more consistent with `convergence make`

# Arguments
- `par`: The name of the parameter to read from the OUTCAR file (e.g., `eigenvalues`, `forces`, or any specific value like `NIONS`).
- `outcar`: Name of the OUTCAR file to read (optional; default is "OUTCAR").
- `p`: Path to the OUTCAR file (optional, defaults to the current directory).
- `o`: Output file where the data should be saved (optional; if it contains "h5", the data will be saved in HDF5 format).
"""
run_task(::Type{Val{:convergence}}, ::Type{Val{:read}}, args) = run_task(Val{Symbol("outcar")}, Val{Symbol("read")}, args)