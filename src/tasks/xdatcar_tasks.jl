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
    lattice, configs = read_xdatcar(joinpath(args["p"], args["xdatcar"]))

    if lowercase(args["par"]) == "msd"
        poscar = read_poscar(joinpath(args["p"], args["poscar"]))
        msd, err = get_msd(poscar.rs_atom, configs, lattice)
        return ["msd", "deviation"], [msd, err]
    end

    return ["lattice", "configs"], [lattice, configs]
end