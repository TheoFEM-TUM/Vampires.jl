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
* `vamp incar sample`: Sample configurations from an XDATCAR file and store them in individual POSCARs.
"""
run_task(::Type{Val{:supercell}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp supercell make --N <scaling_factors> [--poscar <file>] [--o <output_file>] [--p <path>]

Create a supercell from a given POSCAR file by scaling the unit cell according to specified factors.

# Arguments
- `N`: Scaling factors for the supercell, specified as a comma-separated list (e.g., `2,2,2`). If not using commas, a single integer is interpreted as a uniform scaling factor for all dimensions.
- `poscar`: Path to the POSCAR file that contains the original unit cell (optional; default is "POSCAR").
- `o`: Name of the output file where the new POSCAR data will be written (optional; default is "SC_POSCAR").
- `p`: Sets the pathW (optional).

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
    poscar = read_poscar(joinpath(args["p"], args["poscar"]))
    N = occursin(',', args["N"]) ? split_line(args["N"], char=',') : args["N"]
    N = parse.(Int64, N)
    sc_poscar = transform_primitive_cell(poscar, N)
    filename = args["o"] == "none" ? "SC_POSCAR" : args["o"]
    write_poscar(sc_poscar, filename=args["p"]*filename)
    return nothing
end

"""
    vamp supercell sample --N <size,minimum_index> [--xdatcar <file>] [--method <method>] [--p <path>]

Sample configurations from a XDATCAR file and create a folder for each one. Copy VASP input files into each folder if present.

# Arguments
- `N`: Defines the sample size, and the minimum index (in the XDATCAR) that can be sampled, e.g., `-N 10, 1000` results in a sample size of 10 with the minimum index being 1000. If only one value is provided, `Nmin` is set to 1.
- `xdatcar`: Path to the XDATCAR file that contains the atomic positions for sampling (optional; default is "XDATCAR").
- `method`: Method used for sampling configurations (optional; default is `random`). Alternatively, uniform sampling may be used.
- `p`: Sets the path where the supercell and sample configurations will be created (optional).

# Examples
```bash
# Example 1: Sample 10 random configurations from the XDATCAR file.
vamp supercell sample --N 10

# Example 2: Sample 100 configurations from a custom XDATCAR file using a custom POSCAR file, with the "uniform" sampling method.
vamp supercell sample --N 100,4000 --xdatcar custom_XDATCAR --method uniform
```
"""
function run_task(::Type{Val{:supercell}}, ::Type{Val{:sample}}, args)
    poscar = joinpath(args["p"], args["poscar"])
    xdatcar = joinpath(args["p"], args["xdatcar"])
    incar = joinpath(args["p"], args["incar"])
    kpoints = joinpath(args["p"], args["kpoints"])
    potcar = joinpath(args["p"], args["potcar"])
    Ns = parse.(Int64, split_line(args["N"], char=','))
    N, Nmin = length(Ns) > 1 ? Ns : (Ns[1], 1)
    supercell_create_subdirectories(args["p"], xdatcar, N, method=args["method"], Nmin=Nmin, potcar=potcar, kpoints=kpoints, incar=incar)
    return nothing
end