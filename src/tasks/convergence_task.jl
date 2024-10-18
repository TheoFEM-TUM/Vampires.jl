"""
list of available tasks:

convergence
    make: creates the folder structure where the specified parameter is changed in the different subdirectories
    read: reads a specific output (e.g., energy) from a convergence test
    plot: plots a specific output (e.g., TOTEN) vs folder seed (e.g., ENCUT)
"""
# TODO: unify this with time series and ionic relaxation

"""
    vamp [-r] convergence make --par <parameter> --val <range> [--method <method>] [--p <path>]

Create subdirectories for convergence tests, each with varying values for the specified parameter.

# Arguments
- `par`: The parameter for which the convergence test will be run (e.g., `ENCUT`, `kgrid`, etc.).
- `val`: A comma-separated range of values to use for the parameter (e.g., `400,500,600`).
- `method`: The method for generating the k-grid, only relevant for k-grid convergence.
- `p`: The path where subdirectories for the convergence tests will be created (optional; defaults to the current directory).

# Examples
```bash
# Example 1: Create subdirectories for ENCUT convergence with values 400, 500, and 600.
vamp convergence make --par ENCUT --val 400,500,600

# Example 2: Create subdirectories for k-grid convergence with values 2x2x2, 3x3x3, and 4x4x4 using a Monkhorst-Pack grid.
vamp convergence make --par kgrid --val 2,3,4 --method mp

# Example 3: Generate subdirectories for a logarithmic convergence test for LREAL with values True and False in a specified folder.
vamp convergence make --par LREAL --val True,False --path lreal_tests
"""
function run_task(::Type{Val{:convergence}}, ::Type{Val{:make}}, args)
    param = args["par"]
    param_range = split(args["val"], ",")
    path = args["p"]
    convergence_create_subdirectories(param, param_range; path=path, method=args["method"])
end


# TODO: make sure, that matching non-recursive and recursive tasks are matched in Documentation

# TODO: deprecate this?
run_task(::Type{Val{:convergence}}, ::Type{Val{:read}}, args) = run_task(Val{Symbol("outcar")}, Val{Symbol("read")}, args)
