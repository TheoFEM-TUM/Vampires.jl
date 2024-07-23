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

function run_task(::Type{Val{:convergence}}, ::Type{Val{:read}}, args)
    read_value_from_outcar(args["par"], args["p"]*args["outcar"])
end