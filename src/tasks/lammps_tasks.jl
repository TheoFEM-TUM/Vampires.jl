"""
list of available tasks:


lammps:
    read: read the atomic configurations from the LAMMPS dump output file.
"""


"""
# CLI Commands to work with the LAMMPS dump output file

Available commands:
* `vamp lammps read`: read the data from the LAMMPS file.
"""
run_task(::Type{Val{:lammps}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] lammps read --lmp_file <file> [--p <path>] [--o <file>]

Reads atomic configurations from an LAMMPS file and calculates specific properties, such as mean squared displacement (MSD), based on the specified parameter.

# Arguments
- `lmp_file`: The name of the LAMMPS file containing atomic configurations from a molecular dynamics simulation.
- `p`: (Optional) The path where the LAMMPS files are located.
- `o`: (Optional) The name of the output file.

# Returns
- Returns the lattice vectors and configurations from the XDATCAR file.

# Examples
# Read atomic configurations and output the lattice vectors and the positions
vamp lammps read --lmp_file position.lammpstrj --p /home/LAMMPS/ --o structures.h5
```
"""
function run_task(::Type{Val{:lammps}}, ::Type{Val{:read}}, args)
    if !check_required_parameters(["lmp_file"], args); return; end
    lammps = read_lammps(joinpath(args["p"], args["lmp_file"]), args["npt"])
    return (lattice = lammps.lattice, configs = lammps.positions)
end
