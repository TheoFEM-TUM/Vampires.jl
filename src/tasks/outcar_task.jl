"""
list of available tasks:

outcar
    read: read a certain value from the outcar file
"""



function run_task(::Type{Val{:outcar}}, ::Type{Val{:read}}, args)
    values = read_value_from_outcar(args["par"], args["p"]*args["outcar"])
    return values
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