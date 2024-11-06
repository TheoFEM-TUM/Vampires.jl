"""
list of available tasks:


eigenval:
    read: read the data from the eigenval file.
    plot: plot the bandstructure from the eigenval file.
"""


"""
# CLI Commands to work with the EIGENVAL file

Available commands:
* `vamp eigenval read`: read the data from the eigenval file.
* `vamp eigenval plot`: plot the bandstructure from the eigenval file.
"""
run_task(::Type{Val{:eigenval}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] eigenval read [--p <path>] [--eigenval <file>] [--o <output_file>]

Reads eigenvalue data from an EIGENVAL file, processes the k-points, eigenvalues, and occupations, and writes the result to an output file in HDF5 format.

# Arguments
- `p`: The path where the EIGENVAL file is located. The full path is constructed using this argument and the `eigenval` argument.
- `eigenval`: Name of the EIGENVAL file to read (optional; default path is given by `p`).
- `o`: Name of the output file where the results (k-points, eigenvalues, occupations) will be written. The default output format is HDF5, and the default file name is `eigenval.h5`. If not specified, "eigenval.h5" is used.
- `par`: A specific parameter to read.

# Behavior
- The function reads the k-points, eigenvalues, and occupations from the EIGENVAL file located at the specified path.
- It processes the data and writes it to an HDF5 file. If the output file does not end with `.h5`, the function throws an error, as only HDF5 output is supported.
- In recursive mode, the data of all EIGENVAL files is written to the same output file.

# Examples
```bash
# Example 1: Read from the default EIGENVAL file and write to a HDF5 file.
vamp eigenval read --p /path/to/dir --o eigenval.h5

# Example 2: Specify a custom EIGENVAL file that is read from multiple subfolders.
vamp eigenval read -r --eigenval EIGENVAL_custom --o eigenval.h5

# Example 3: Read the bandgap from the EIGENVAL file.
vamp eigenval read --par bandgap
"""
function run_task(::Type{Val{:eigenval}}, ::Type{Val{:read}}, args)
    input_filename = args["p"] * args["eigenval"]
    output_filename = args["o"]
    kp, Es, occs = read_eigenval(input_filename)
    if args["par"] == "bandgap"
        ΔE = get_bandgap(Es, occs, printit=args["v"])
        if occursin("h5", output_filename)
            write_data_to_hdf5(output_filename, ["bandgap"], [ΔE])
        else
            if !args["r"]; println("The bandgap is: $ΔE eV."); end
            return ΔE
        end
    elseif occursin("h5", output_filename)
        write_data_to_hdf5(output_filename, ["kpoints", "eigenvalues", "occupations"], [kp, Es, occs])
    elseif args["par"] == "effective_mass"
        N = parse(Int64, args["N"] == "0" ? "3" : args["N"])
        kpoint = parse.(Float64, split_line(args["kpoints"], char=','))
        k_ind = find_kpoint(kpoint, kp)
        lattice = read_poscar(joinpath(args["p"], args["poscar"])).lattice
        meffs = map(eachrow(Es)) do E_band
            get_effective_mass(kp[:, k_ind:k_ind+N], E_band[k_ind:k_ind+N], lattice, method=args["method"])
        end
        return ["effective_mass"], [meffs]
    else
        throw("Unknown output file format.")
    end
end

"""
    vamp eigenval plot [--p <path>] [--eigenval <file>] [--o <output_filename>]

Reads the eigenvalues from an EIGENVAL file and generates a plot of the electronic bandstructure.

# Arguments
- `p`: Path to the directory containing the EIGENVAL file.
- `eigenval`: Name of the EIGENVAL file to read from.
- `o`: Output filename for the plot (optional). If not specified, the plot is shown but not saved.

# Behavior
- Reads the eigenvalues and k-points from the specified EIGENVAL file.
- Generates a plot of the electronic band structure.

# Examples
```bash
# Example 1: Plot band structure from an EIGENVAL file and save to an image file.
vamp eigenval plot --p /path/to/files --eigenval EIGENVAL --o bandstructure.png
"""
function run_task(::Type{Val{:eigenval}}, ::Type{Val{:plot}}, args)
    output_filename = args["o"]
    input_filename = args["p"] * args["eigenval"]
    kp, Es, _ = read_eigenval(input_filename)
    plot_bandstructure(Es, kp, output_filename)
end