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
    keyword = "CPU"
    kpar_range = args["kpar"]
    ncore_nsim_range = args["ncore"]
    path = args["p"]
    verbose = args["v"]
    time = args["N"]
    avail_cpus_per_node = args["avail_cpus_per_node"]
    strong_scaling_create_subdirectories(kpar_range, ncore_nsim_range; path=path, verbose=verbose, keyword=keyword, time=time, avail_cpus_per_node=avail_cpus_per_node)
end



function run_task(::Type{Val{:weak_scaling}}, ::Type{Val{:cpu}}, args)
    param = args["par"]
    param_range = split(args["val"], ",")
    path = args["p"]
    weak_scaling_create_subdirectories(param, param_range; path=path)
end