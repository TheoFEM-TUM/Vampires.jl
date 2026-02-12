"""
list of available tasks:

supercell
    make: create a supercell POSCAR file from an existing POSCAR file
    sample: create folders that each contains one snapshot from an XDATCAR file and other VASP input files
"""



"""
# CLI Commands to work with the supercells
The following command can be used to create or work with supercells (i.e., POSCAR and XDATCAR files).

Available commands:
* `vamp supercell make`: Create an supercell POSCAR from a primitive cell poscar.
* `vamp supercell sample`: Sample configurations from an XDATCAR file and store them in individual POSCARs.
"""
run_task(::Type{Val{:supercell}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp supercell make --N <scaling_factors> [--poscar <file>] [--o <output_file>] [--p <path>]

Create a supercell from a given POSCAR file by scaling the unit cell according to specified factors.

# Arguments
- `N`: Scaling factors for the supercell, specified as a comma-separated list (e.g., `2,2,2`). If not using commas, a single integer is interpreted as a uniform scaling factor for all dimensions.
- `poscar`: Path to the POSCAR file that contains the original unit cell (optional; default is "POSCAR").
- `o`: Name of the output file where the new POSCAR data will be written (optional; default is "SC_POSCAR").
- `p`: Sets the path (optional).

# Behavior
- The function reads the POSCAR file, scales the unit cell by the specified factors, and writes the resulting supercell to a new POSCAR file.
- The scaling factors can be provided as a single integer or as a comma-separated list to specify different factors for each dimension.

# Examples
```bash
# Example 1: Create a supercell with scaling factors 2x2x2 and save to the default file name "SC_POSCAR".
vamp supercell make --N 2,2,2

# Example 2: Create a supercell with scaling factor 3 in all dimensions using a custom output file name "supercell_POSCAR".
vamp supercell make --N 3 --o supercell_POSCAR

# Example 3: Create a supercell from a POSCAR file located in the 'structure' folder with scaling factors 1,2,3 and save to the default file name.
vamp supercell make --N 1,2,3 --poscar structure/POSCAR
```
"""
function run_task(::Type{Val{:supercell}}, ::Type{Val{:make}}, args)
    if !check_required_parameters(["N"], args); return; end
    poscar = read_poscar(joinpath(args["p"], args["poscar"]))
    N = occursin(',', args["N"]) ? split_line(args["N"], char=',') : args["N"]
    N = parse.(Int64, N)
    sc_poscar = transform_primitive_cell(poscar, N)
    filename = args["o"] == "none" ? "SC_POSCAR" : args["o"]
    write_poscar(sc_poscar, filename=args["p"]*filename)
    return nothing
end

"""
    vamp supercell sample --N <size,minimum_index> [--xdatcar <file>] [--method <method>] [--p <path>] [--lammps]

Sample configurations from a XDATCAR file and create a folder for each one. Copy VASP input files into each folder if present.

# Arguments
- `N`: Defines the sample size, and the minimum index (in the XDATCAR) that can be sampled, e.g., `-N 10, 1000` results in a sample size of 10 with the minimum index being 1000. If only one value is provided, `Nmin` is set to 1.
- `xdatcar`: (Optional) Path to the XDATCAR file that contains the atomic positions for sampling (optional; default is "XDATCAR").
- `method`: (Optional) Method used for sampling configurations (optional; default is `random`). Alternatively, uniform sampling may be used.
- `p`: (Optional) Sets the path where the supercell and sample configurations will be created (optional).
- `lammps`: (Optional) If set to true, the script read lammps input files instead of VASP XDATCAR.

# Examples
```bash
# Example 1: Sample 10 random configurations from the XDATCAR file.
vamp supercell sample --N 10

# Example 2: Sample 100 configurations from a custom XDATCAR file using a custom POSCAR file, with the "uniform" sampling method.
vamp supercell sample --N 100,4000 --xdatcar custom_XDATCAR --method uniform
```
"""
function run_task(::Type{Val{:supercell}}, ::Type{Val{:sample}}, args)
    if !check_required_parameters(["N"], args); return; end
    poscar = joinpath(args["p"], args["poscar"])
    xdatcar = joinpath(args["p"], args["xdatcar"])
    incar = joinpath(args["p"], args["incar"])
    kpoints = joinpath(args["p"], args["kpoints"])
    potcar = joinpath(args["p"], args["potcar"])
    include_files = split_line(args["include"], char=',')

    Ns = parse.(Int64, split_line(args["N"], char=','))
    N, Nmin = length(Ns) > 1 ? Ns : (Ns[1], 1)
    supercell_create_subdirectories(args["p"], xdatcar, N, method=args["method"], Nmin=Nmin, potcar=potcar, kpoints=kpoints, incar=incar, include_files=include_files, lammps=args["lammps"])
    return nothing
end

"""
    vamp supercell rattle --N <int> [--poscar <file>] [--method <method>]
                            [--p <path>] [--par <params>] [--val <values>] [--o <output>]

Rattle a POSCAR structure and generate multiple distorted configurations.  
All generated structures are written to a single XDATCAR file.

# Arguments
- `N` : Number of configurations to create.
- `method` : (Optional) Method used for random numbers; `"gaussian"` (default) or `"uniform"`.
- `p` : (Optional) Path where sampled supercells will be created. Default: current directory.
- `par` : (Optional) Comma-separated list of additional keyword parameters, e.g., `sigma_min,sigma_max,strain_max`.
- `val` : (Optional) Comma-separated list of values corresponding to `--par`.

# Additional rattle parameters (passed via `--par` and `--val`)
- `sigma_min` : Minimum atomic displacement amplitude (Å). Default: 0.03
- `sigma_max` : Maximum atomic displacement amplitude (Å). Default: 0.10
- `min_dist_factor` : Minimum allowed distance between atoms relative to the reference structure. Default: 0.8
- `strain_max` : Maximum isotropic lattice strain (fractional). Default: 0.0
- `N` : Number of configurations to generate. Default: 1
- `method` : Displacement method; `"gaussian"` or `"uniform"`. Default: `"gaussian"`
- `attempt_max` : Maximum number of attempts to generate a valid configuration before giving up. Default: 20
- `alpha` : Mass scaling exponent; determines how displacement scales with atom mass. Default: 0.5
             (1 → lightest atom moves full sigma, heavier atoms scaled down relative to lightest)

# Examples
```bash
# Example 1: Sample 10 random configurations from the default POSCAR file
vamp supercell rattle --N 10

# Example 2: Sample 100 configurations using uniform displacements
vamp supercell rattle --N 100 --method uniform

# Example 3: Sample 5 configurations and pass custom rattle_cell parameters (sigma_min and sigma_max)
vamp supercell rattle --N 5 --par sigma_min,sigma_max --val 0.02,0.08

# Example 4: Sample configurations from a custom POSCAR file in a custom output path
vamp supercell rattle --N 10 --poscar my_POSCAR --p ./samples

# Example 5: Sample 10 configurations with isotropic strain and stronger mass scaling (heavy atoms move less)
vamp supercell rattle --N 10 --par strain_max,alpha --val 0.1,1

# Example 6: Sample 10 configurations with increased attempt_max and reduced min_dist_factor
vamp supercell rattle --N 10 --par attempt_max,min_dist_factor --val 100,0.5
```
"""
function run_task(::Type{Val{:supercell}}, ::Type{Val{:rattle}}, args)
    if !check_required_parameters(["N"], args); return; end
    poscar = read_poscar(joinpath(args["p"], args["poscar"]))
    
    N = parse.(Int64, args["N"])
    method = args["method"] == "none" ? "gaussian" : args["method"]
    params = split_line(args["par"], char=',')
    vals = parse.(Float64, split_line(args["val"], char=','))
    @assert length(params) == length(vals)
    func_args = NamedTuple{Tuple(Symbol.(params))}(vals)
    strc_out = rattle_cell(poscar, method=method, N=N; func_args...)

    open(joinpath(args["p"], args["o"]), "w") do file
        write_xdatcar(file, strc_out)
    end
    return nothing
end