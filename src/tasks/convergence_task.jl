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
    convergence_create_subdirectories(param, param_range; path="./")

Creates subdirectories for a parameter convergence study and copies necessary VASP input files into each subdirectory.

# Arguments
- `param::String`: The parameter to be varied for the convergence study.
- `param_range::AbstractVector`: A range or array of parameter values to be used for the subdirectories.
- `path::String`: The base path where the subdirectories will be created. Defaults to `"./"`.
"""
function convergence_create_subdirectories(param, param_range; path="./")
    for value in param_range
        folder = param*"_"*value
        mkdir(path*folder)
        for file in ["KPOINTS", "POTCAR", "POSCAR"]
            if file in readdir(path)
                cp(path*file, path*folder*"/$file", force=true)
            end
        end
        set_keyword_in_incar!(param, value, path*"INCAR", out=path*folder*"/INCAR")
    end
end

"""
    convergence_read_value(param, path)

Reads and prints the value of a specified parameter from a VASP OUTCAR file.

# Arguments
- `param::String`: The parameter to be read from the OUTCAR file.
- `path::String`: The path to the directory containing the OUTCAR file.
"""
function convergence_read_value(param, path)
    value = read_value_from_file(param, path*"OUTCAR")
    println("The value of $param in $path is: $value")
end