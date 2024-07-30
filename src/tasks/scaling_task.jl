"""
list of available tasks:

strong_scaling
    cpu: create a folder structure with slurm files to analyze CPU scaling in VASP
    gpu: create a folder structure with slurm files to analyze GPU scaling in VASP

weak_scaling
    cpu: create a folder structure with slurm files to analyze weak CPU scaling in VASP
    gpu: create a folder structure with slurm files to analyze weak GPU scaling in VASP
"""


function run_task(::Type{Val{:strong_scaling}}, ::Type{Val{:cpu}}, args)
    param = args["par"]
    param_range = split(args["val"], ",")
    path = args["p"]
    strong_scaling_create_subdirectories(param, param_range; path=path)
end


function run_task(::Type{Val{:weak_scaling}}, ::Type{Val{:cpu}}, args)
    param = args["par"]
    param_range = split(args["val"], ",")
    path = args["p"]
    weak_scaling_create_subdirectories(param, param_range; path=path)
end