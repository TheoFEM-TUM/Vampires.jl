"""
list of available tasks:

w90_hr
    read: read the W90 Hamiltonian from the *_hr.dat file
"""


"""
# CLI Commands to work with the Wannier90 hr file

Available commands:
* `vamp w90_hr read`: Read the Wannier90 `w90_hr.dat` file and export its data.
"""
run_task(::Type{Val{:w90_hr}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] w90_hr read [--w90_hr <file>] [--o <output_file>]

Read the Wannier90 `w90_hr.dat` file and export its data in HDF5 format.

# Arguments
- `w90_hr`: Path to the `w90_hr.dat` file to be read.
- `o`: Name of the output file (optional; defaults to "w90_hr.h5"). The output must be in HDF5 format.

# Behavior
- This function reads the Hamiltonian matrix (`Hr`), lattice vectors (`Rs`), and degeneracies (`deg`) from the specified Wannier90 `w90_hr.dat` file.
- If the output file is in HDF5 format, the function saves the read data as datasets within the HDF5 file.
- If `r` is true, the Hamiltonians, degeneracies and lattice vectors are read from each subfolder and stored in the same output file.

# Examples
```bash
# Example 1: Read data from a w90_hr.dat file and save it to a default HDF5 file.
vamp w90_hr read --w90_hr /path/to/w90_hr.dat

# Example 2: Read data from 
vamp w90_hr read --w90_hr /path/to/w90_hr.dat --o /path/to/output.h5
"""
function run_task(::Type{Val{:w90_hr}}, ::Type{Val{:read}}, args)
    input_filename = joinpath(args["p"], args["w90_hr"])
    output_filename = args["o"] == "none" ? "w90_hr.h5" : args["o"]
    Hr, Rs, deg = read_hrdat(input_filename)
    if occursin("h5", output_filename)
        write_data_to_hdf5(output_filename, ["Hr", "Rs", "degeneracies"], [Hr, Rs, deg])
    else
        throw("Unknown output file format.")
    end
end
