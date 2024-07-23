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
    convergence_read_value(args["par"], args["p"])
end

function run_task(::Type{Val{:convergence}}, ::Type{Val{:plot}}, args)
    #TODO: What should this do?
    throw("convergence plots are currently only implemented in recursive mode.")
end

function run_task_recursive(::Type{Val{:convergence}}, ::Type{Val{:plot}}, args)
    convergence_plot_value(args["par"], args["p"], args["o"])
end

"""
    convergence_read_value(param, path)

Reads and prints the value of a specified parameter from a VASP OUTCAR file.

# Arguments
- `param::String`: The parameter to be read from the OUTCAR file.
- `path::String`: The path to the directory containing the OUTCAR file.
"""
function convergence_read_value(param, path)
    value = read_value_from_outcar(param, path*"OUTCAR")[end]
    println("The value of $param in $path is: $value")
end