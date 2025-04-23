"""
list of available tasks:

poscar
    read: read the POSCAR file
"""


"""
    vamp [-r] poscar read [--poscar <file>] [--o <output_file>]

Read the POSCAR file and export its data.

# Arguments
- `poscar`: (Optional) Path to the `POSCAR` file to be read.
- `o`: (Optional) Name of the output file.

# Examples
```bash
# Example 1: Read data from a POSCAR file and save it to a HDF5 file.
vamp poscar read --poscar SOME_POSCAR --o poscar.h5
```
"""
function run_task(::Type{Val{:poscar}}, ::Type{Val{:read}}, args)
    input_filename = joinpath(args["p"], args["poscar"])
    poscar = read_poscar(input_filename)
    return (lattice = poscar.lattice, positions = poscar.positions, atom_types = poscar.atom_types)
end