"""
list of available tasks:

convergence
    create: creates the folder structure where the specified parameter is changed in the different subdirectories
    read: reads a specific output (e.g., energy) from a convergence test
"""
# TODO: unify this with time series and ionic relaxation


function run_task(::Type{Val{:convergence}}, ::Type{Val{:create}}, args)
    param = args["par"]
    param_range = split(args["val"], ",")
    path = args["p"]
    convergence_create_subdirectories(param, param_range; path=path)
end

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

function run_task(::Type{Val{:convergence}}, ::Type{Val{:read}}, args)
    return 0
end