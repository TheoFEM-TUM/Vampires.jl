"""
list of available tasks:

outcar
    read: read a certain value from the outcar file
"""


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
"""
function run_task(::Type{Val{:outcar}}, ::Type{Val{:read}}, args)
    param = args["par"]
    output_filename = args["o"]

    if occursin("h5", output_filename) && param == "eigenvalues"
        kp, Es, occs = read_eigenvalues_from_outcar(args["p"]*args["outcar"])
        write_data_to_hdf5(output_filename, ["kpoints", "eigenvalues", "occupations"], [kp, Es, occs])
        println("Data for $param was saved to $output_filename.")
    elseif occursin("h5", output_filename) && param == "forces"
        positions, forces = read_forces_from_outcar(args["p"]*args["outcar"])
        write_data_to_hdf5(output_filename, ["positions", "forces"], [positions, forces])
        println("Data for $param was saved to $output_filename.")
    else
        values = read_value_from_outcar(param, args["p"]*args["outcar"])
        value = strip(string(values), ['[', ']'])
        if !args["r"]
            println("The value(s) for $param is $value")
        end
        return values
    end
end

"""
    vamp [-r] outcar plot [--par <parameter>] [--p <path>] [--outcar <file>] [--o <figure_name>]

Read specific data from the OUTCAR file and plot the values.

# Arguments
- `par`: The name of the parameter to read from the OUTCAR file.
- `p`: Path to the OUTCAR file (optional, defaults to the current directory).
- `outcar`: Name of the OUTCAR file to read (optional; default is "OUTCAR").
- `o`: Name of the figure the plot is saved to.

# Behavior
- The function reads the specified parameter (`par`) from the OUTCAR file, retrieves its values, and plots them using a basic plot function.
- If `-r`, assumes one value per OUTCAR and plots each value vs the name of the folder
- If not `-r`, assumes multiple values and plots them vs their occurence (e.g., the iteration number or time step).

# Examples
```bash
# Example 1: Plot the temperature from the OUTCAR file vs the iteration number.
vamp outcar plot --par temperature --p /path/to/ --outcar OUTCAR

# Example 2: Plot the total energy for each subfolder (e.g., convergence testing).
vamp -r outcar plot --par TOTEN
"""
function run_task(::Type{Val{:outcar}}, ::Type{Val{:plot}}, args)
    values = read_value_from_outcar(args["par"], args["p"]*args["outcar"])
    plot(values)
end

function run_task_recursive(::Type{Val{:outcar}}, ::Type{Val{:plot}}, args)
    y_values = Float64[]
    x_values = Float64[]
    base_path = args["p"]
    x_par_name = ""
    for (i, folder) in enumerate(readfolders(base_path))
        if i == 1; x_par_name = split(folder, "_")[1]; end
        args["p"] = joinpath(base_path, folder * "/")
        push!(x_values, parse(Float64, split(folder, "_")[2]))
        y_value = read_value_from_outcar(args["par"], args["p"]*args["outcar"])[end]
        push!(y_values, y_value)
    end
    inds = sortperm(x_values)
    plot_value_convergence(x_par_name, args["par"], x_values[inds], y_values[inds], args["o"])
end