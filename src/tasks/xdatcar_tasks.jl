"""
list of available tasks:


xdatcar:
    read: read the atomic configurations from the XDATCAR file.
"""


"""
# CLI Commands to work with the XDATCAR file

Available commands:
* `vamp xdatcar read`: read the data from the XDATCAR file.
"""
run_task(::Type{Val{:xdatcar}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] xdatcar read [--par <param>] [--xdatcar <file>] [--poscar <file>] [--p <path>] [--o <file>]

Reads atomic configurations from an XDATCAR file and calculates specific properties, such as mean squared displacement (MSD), based on the specified parameter.

# Arguments
- `par`: Specifies the property to calculate. Accepted values:
    - `"msd"`: Computes the mean squared displacement (MSD) and its standard deviation relative to the initial atomic positions in the POSCAR file.
- `xdatcar`: The name of the XDATCAR file containing atomic configurations from a molecular dynamics simulation.
- `poscar`: The name of the POSCAR file containing the initial atomic configuration (required if `par` is `"msd"`).
- `p`: The path where the XDATCAR and POSCAR files are located.
- `o`: The name of the output file.

# Returns
- If `par` is `"msd"`: Returns MSD and its standard deviation
- Otherwise: Returns the lattice vectors and configurations from the XDATCAR file.

# Examples
```bash
# Example 1: Read atomic configurations and save them to a file
vamp xdatcar read --xdatcar XDATCAR --out configurations.h5

# Example 2: Calculate the MSD for an MD trajectory
vamp xdatcar read --par MSD
```
"""
function run_task(::Type{Val{:xdatcar}}, ::Type{Val{:read}}, args)
    xdatcar = read_xdatcar(joinpath(args["p"], args["xdatcar"]))
    lattice, configs = xdatcar.lattice, xdatcar.positions

    if lowercase(args["par"]) == "msd"
        poscar = read_poscar(joinpath(args["p"], args["poscar"]))
        msd, err = get_msd(poscar.positions, configs, lattice)
        return ["msd", "deviation"], [msd, err]
    end

    return ["lattice", "configs"], [lattice, configs]
end

"""
    vamp [-r] xdatcar merge [--xdatcar <file0, file1, ...>] [--p <path>] [--o <file>]

Merges atomic configurations from several XDATCARs in the given order and writes them to an output file.

# Arguments
- `xdatcar`: The name of the XDATCAR files from an molecular dynamics simulation in the order they should be merged.
- `p`: The path where the XDATCAR files are located.
- `o`: The name of the output file.

# Returns
- Otherwise: Returns the lattice vectors and configurations from the XDATCAR file.

# Examples
```bash
# Example 1: Merge two XDATCAR_* files to a single XDATCAR
vamp xdatcar merge --xdatcar XDATCAR_0-100,XDATCAR_101-200 --out XDATCAR
```
"""
function run_task(::Type{Val{:xdatcar}}, ::Type{Val{:merge}}, args)
    lattice_n, configs_n = Float64[], Float64[]
    for xdatcar_file_i in args["xdatcar"]
        lattice, configs = read_xdatcar(joinpath(args["p"], xdatcar_file_i))
        push!(lattice_n, lattice)
        push!(configs_n, configs)
    end
    output_filename = args["o"] == "none" ? "XDATCAR_merged" : args["o"]
    write_combined_xdatcar(lattice_n, configs_n, joinpath(args["p"], output_filename))
end