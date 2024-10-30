"""
list of available tasks:

doscar
    read: read-in the doscar file
    plot: plot the dos from the doscar file
"""


"""
# CLI Commands to work with the DOSCAR file

Available commands:
* `vamp doscar read`: read the doscar file.
* `vamp doscar plot`: plot the dos from the doscar file
"""
run_task(::Type{Val{:doscar}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp doscar read [--doscar <file>] [--o <output_filename>]

Reads the density of states (DOS) data from a DOSCAR file and writes the results to an HDF5 file if specified.

# Arguments
- `doscar`: Path to the DOSCAR file to read from.
- `o`: Output filename where the processed data will be saved. If the filename contains 'h5', the data is saved in HDF5 format.

# Behavior
- Reads the DOS data from the specified DOSCAR file.
- If the output file is in HDF5 format, it writes the energy, DOS, and integrated DOS (IDOS) data to the specified file in HDF5 format.

# Examples
```bash
# Example 1: Read DOSCAR data and save it to an HDF5 file.
vamp doscar read --doscar DOSCAR --o output.h5
"""
function run_task(::Type{Val{:doscar}}, ::Type{Val{:read}}, args)
    output_filename = args["o"]
    dos, _ = read_doscar(args["doscar"])
    if occursin("h5", output_filename)
        write_data_to_hdf5(output_filename, ["energy", "dos", "idos"], [dos[:, 1], dos[:, 2], dos[:, 3]])
    end
end

"""
    vamp doscar plot [--p <path>] [--doscar <file>] [--o <output_filename>]

Reads the density of states (DOS) data from a DOSCAR file and generates a plot of the DOS.

# Arguments
- `p`: Path to the directory containing the DOSCAR file.
- `doscar`: Name of the DOSCAR file to read from.
- `o`: Output filename for the plot (optional). If not specified, the plot is shown but not saved.

# Behavior
- Reads the DOS data from the specified DOSCAR file.
- Generates a plot of the density of states (DOS).

# Examples
```bash
# Example 1: Plot DOS data from a DOSCAR file and save it to an image file.
vamp doscar plot --p /path/to/files --doscar DOSCAR --o dos_plot
"""
function run_task(::Type{Val{:doscar}}, ::Type{Val{:plot}}, args)
    input_filename = args["p"] * args["doscar"]
    dos, _ = read_doscar(input_filename)
    plot_dos(dos, args["o"])    
end