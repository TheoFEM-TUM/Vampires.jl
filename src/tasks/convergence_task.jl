"""
list of available tasks:

convergence
    create: creates the folder structure where the specified parameter is changed in the different subdirectories
    read: reads a specific output (e.g., energy) from a convergence test
    plot: plots a specific output (e.g., TOTEN) vs folder seed (e.g., ENCUT)
"""
# TODO: unify this with time series and ionic relaxation


function run_task(::Type{Val{:convergence}}, ::Type{Val{:create}}, args)
    param = args["par"]
    param_range = split(args["val"], ",")
    path = args["p"]
    convergence_create_subdirectories(param, param_range; path=path)
end


# TODO: make sure, that matching non-recursive and recursive tasks are matched in Documentation

function run_task_recursive(::Type{Val{:convergence}}, ::Type{Val{:plot}}, args)
    y_values = Float64[]
    x_values = []
    base_path = args["p"]
    x_par_name = ""
    for (i, folder) in enumerate(readfolders(base_path))
        if i == 1; x_par_name = split(folder, "_")[1]; end
        args["p"] =  joinpath(base_path, folder * "/")
        push!(x_values, split(folder, "_")[2])
        y_value = read_value_from_outcar(args["par"], args["p"]*args["outcar"])[end]
        push!(y_values, y_value)
    end
    plot_value_convergence(x_par_name, args["par"], x_values, y_values, args["o"])
end

run_task(::Type{Val{:convergence}}, ::Type{Val{:read}}, args) = run_task(Val{Symbol("outcar")}, Val{Symbol("read")}, args)
