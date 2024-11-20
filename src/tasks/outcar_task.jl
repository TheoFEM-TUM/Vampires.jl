"""
list of available tasks:

outcar
    read: read a certain value from the outcar file
    plot: plot a series of values from an OUTCAR file. If recursive, plot one value from an OUTCAR file in multiple folders.
"""


"""
# CLI Commands to work with the OUTCAR file
The following command can be used to analyze or plot values from an OUTCAR file.

Available commands:
* `vamp outcar read`: read a certain value from the outcar file.
* `vamp outcar plot`: plot a series of values from an OUTCAR file. If recursive, plot one value from an OUTCAR file in multiple folders..
"""
run_task(::Type{Val{:outcar}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] outcar read [--par <parameter>] [--p <path>] [--outcar <file>] [--o <output>]

Read specific data from the OUTCAR file and optionally save the data to an HDF5 file.

# Arguments
- `par`: The name of the parameter to read from the OUTCAR file (e.g., `eigenvalues`, `forces`, or any specific value like `NIONS`).
- `p`: Path to the OUTCAR file (optional, defaults to the current directory).
- `outcar`: Name of the OUTCAR file to read (optional; default is "OUTCAR").
- `o`: Output file where the data should be saved (optional; if it contains "h5", the data will be saved in HDF5 format).

# Behavior
- If `par` is `"eigenvalues"` and the output file (`o`) ends with ".h5", the function reads the k-points, eigenvalues, and occupations from the OUTCAR and saves them in the HDF5 file.
- If `par` is `"forces"` and the output file ends with ".h5", the function reads the ionic positions and forces from the OUTCAR and saves them to the HDF5 file.
- For other parameters, the function reads the specified parameter from the OUTCAR file and prints them.

# Examples
```bash
# Example 1: Read eigenvalues from OUTCAR and save them to an HDF5 file.
vamp outcar read --par eigenvalues --p /path/to/ --outcar OUTCAR --o eigenvalues.h5

# Example 2: Read forces from OUTCAR and save them to an HDF5 file.
vamp outcar read --par forces --outcar OUTCAR --o forces.h5

# Example 3: Read a specific parameter (e.g., NIONS) and print the value to the console.
vamp outcar read --par NIONS

# Example 4: Read a specific parameter (e.g., LOOP+) from the OUTCAR files in all subfolders.
vamp -r outcar read --par LOOP+

# Example 5: Read the bandgap from the OUTCAR file.
vamp outcar read --par bandgap

# Example 6: Read the effective mass at the Gamma point from each configuration in the OUTCAR
using third-order finite differences
vamp outcar read --par effective_mass --kpoints 0,0,0 --N 3 --method fdm
```
"""
function run_task(::Type{Val{:outcar}}, ::Type{Val{:read}}, args)
    param = args["par"]
    input_file = joinpath(args["p"], args["outcar"])

    if param == "eigenvalues"
        kp, Es, occs = read_eigenvalues_from_outcar(input_file)
        return (kpoints = kp, eigenvalues => Es, occupations = occs)
    elseif param == "forces"
        positions, forces = read_forces_from_outcar(input_file)
        return (positions = positions, forces = forces)
    elseif param == "bandgap"
        kp, Es, occs = read_eigenvalues_from_outcar(input_file)
        ΔEs = to_scalar_if_single([get_bandgap(Es[:, :, n], occs[:, :, n], printit=args["v"]) for n in axes(Es, 3)])
        return (bandgap = ΔEs,)
    else
        values = to_scalar_if_single(read_value_from_outcar(param, input_file))
        return NamedTuple(zip([Symbol(param)], [values]))
    end
end