"""
list of available tasks:

outcar
    read: read a certain value from the outcar file
"""


"""
reads last value in OUTCAR of parameter for each directory
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