"""
list of available tasks:

contcar
    read: read a certain value from the contcar file
"""


"""
# CLI Commands to work with the CONTCAR file
The following command can be used to analyze or plot values from an CONTCAR file.

Available commands:
* `vamp contcar read`: read a certain value from the contcar file. E.g., calculate lattice parameter
"""
run_task(::Type{Val{:contcar}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] contcar read --par <parameter> [--contcar <file>] [--p <path>] [--o <output>]

Read specific data from the CONTCAR file and optionally save the data to an HDF5 file.

# Arguments
- `par`: The name of the parameter to read from the CONTCAR file (e.g., `eigenvalues`, `forces`, or any specific value like `NIONS`).
- `contcar`: (Optional) Name of the CONTCAR file to read (optional; default is "CONTCAR").
- `p`: (Optional) Path to the CONTCAR file (optional, defaults to the current directory).
- `o`: (Optional) Output file where the data should be saved (optional; if it contains "h5", the data will be saved in HDF5 format).

# Behavior
- If `par` is `"lattice"` and the output file (`o`) ends with ".h5", the function calculates the lattice parameter from the CONTCAR and saves them in the HDF5 file.

# Examples
```bash
# Example 1: Read eigenvalues from CONTCAR and save them to an HDF5 file.
vamp contcar read --par lattice --p /path/to/ --contcar CONTCAR --o lattice_parameter.h5
```
"""
function run_task(::Type{Val{:contcar}}, ::Type{Val{:read}}, args)
    if !check_required_parameters(["par"], args); return; end
    param = args["par"]
    input_file = joinpath(args["p"], args["contcar"])

    if param == "lattice"
        contcar, velocities = read_contcar(input_file)
        a, b, c, α, β, γ, volume = get_lattice_parameter(contcar)
        return (a = a, b = b, c = c, alpha = α, beta = β, gamma = γ, volume = volume)
    end
end