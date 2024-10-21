"""
list of available tasks:


"""

function run_task(::Type{Val{:eigenval}}, ::Type{Val{:plot}}, args)
    output_filename = args["o"]
    input_filename = args["p"] * args["eigenval"]
    kp, Es, _ = read_eigenval(input_filename)
    plot_bandstructure(Es, kp, output_filename)
end

"""
    vamp [-r] eigenval read [--p <path>] [--eigenval <file>] [--o <output_file>]

Reads eigenvalue data from an EIGENVAL file, processes the k-points, eigenvalues, and occupations, and writes the result to an output file in HDF5 format.

# Arguments
- `p`: The path where the EIGENVAL file is located. The full path is constructed using this argument and the `eigenval` argument.
- `eigenval`: Name of the EIGENVAL file to read (optional; default path is given by `p`).
- `o`: Name of the output file where the results (k-points, eigenvalues, occupations) will be written. The default output format is HDF5, and the default file name is `eigenval.h5`. If not specified, "eigenval.h5" is used.

# Behavior
- The function reads the k-points, eigenvalues, and occupations from the EIGENVAL file located at the specified path.
- It processes the data and writes it to an HDF5 file. If the output file does not end with `.h5`, the function throws an error, as only HDF5 output is supported.
- In recursive mode, the data of all EIGENVAL files is written to the same output file.

# Examples
```bash
# Example 1: Read from the default EIGENVAL file and write to the default HDF5 file.
vamp eigenval read --p /path/to/dir

# Example 2: Specify a custom EIGENVAL file that is read from multiple subfolders.
vamp eigenval read -r --eigenval EIGENVAL_custom
"""
function run_task(::Type{Val{:eigenval}}, ::Type{Val{:read}}, args)
    input_filename = args["p"] * args["eigenval"]
    output_filename = args["o"] == "none" ? "eigenval.h5" : args["o"]
    kp, Es, occs = read_eigenval(input_filename)
    if occursin("h5", output_filename)
        write_data_to_hdf5(output_filename, ["kpoints", "eigenvalues", "occupations"], [kp, Es, occs])
    else
        throw("Unknown output file format.")
    end
end