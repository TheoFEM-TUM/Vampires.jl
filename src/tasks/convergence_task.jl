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
"""
reads last value in OUTCAR of parameter for each directory
"""
function run_task(::Type{Val{:convergence}}, ::Type{Val{:read}}, args)
    values = read_value_from_outcar(args["par"], args["p"]*args["outcar"])
    return values
end



function run_task_recursive(::Type{Val{:convergence}}, ::Type{Val{:plot}}, args)
    collected_values = Float64[]
    x_values = []
    base_path = args["p"]
    param_name = ""
    for (i, folder) in enumerate(readfolders(base_path))
        if i == 1; param_name = split(folder, "_")[1]; end
        args["p"] =  joinpath(base_path, folder * "/")
        # curr_val = run_task(Val{Symbol("calcuation")}, subtask, args)
        push!(x_values, split(folder, "_")[2])
        push!(collected_values, run_task(task, subtask, args))
    end
    plot_value_convergence(string(subtask), param_name, x_values, collected_values, args["o"])
end