"""
list of available tasks:

strong_scaling
    cpu: create a folder structure with slurm files to analyze CPU scaling in VASP
    gpu: create a folder structure with slurm files to analyze GPU scaling in VASP

weak_scaling
    cpu: create a folder structure with slurm files to analyze weak CPU scaling in VASP
    gpu: create a folder structure with slurm files to analyze weak GPU scaling in VASP
"""


function run_task(::Type{Val{:strong_scaling}}, subtask, args)
    keyword = string(subtask)
    if args["ext_par_file"] == "none"; throw("Tasks preparing slurm scripts require a parameter file."); end
    extended_args = read_config(args["ext_par_file"])[args["block"]]
    kpar_range = args["kpar"]
    ncore_nsim_range = keyword == "cpu" ? args["ncore"] : args["nsim"]
    path = args["p"]
    verbose = args["v"]
    vasp_exe = args["vasp_exe"] == "vasp_std" && haskey(extended_args, "vasp_exe") ? extended_args["vasp_exe"] : args["vasp_exe"]
    time = args["N"] == "none" ? extended_args["time"] : args["N"]
    module_path = extended_args["module_path"]
    module_list = extended_args["module_list"]
    partition = extended_args["partition"]
    avail_cpus_per_node = haskey(extended_args, "avail_cpus_per_node") ? extended_args["avail_cpus_per_node"] : 2
    # default has to be 1 to avoid division by zero error
    avail_gpus_per_node = haskey(extended_args, "avail_gpus_per_node") ? extended_args["avail_gpus_per_node"] : 1
    omp_num_threads = extended_args["omp_num_threads"]
    mail = extended_args["mail"]
    strong_scaling_create_subdirectories(kpar_range, ncore_nsim_range; path=path, verbose=verbose, keyword=keyword, time=time,
                                         avail_cpus_per_node=avail_cpus_per_node, avail_gpus_per_node=avail_gpus_per_node,
                                         module_path=module_path, module_list=module_list, vasp_exe=vasp_exe, partition=partition,
                                         omp_num_threads=omp_num_threads, mail=mail)
end

function run_task(::Type{Val{:weak_scaling}}, ::Type{Val{:cpu}}, args)
    param = args["par"]
    param_range = split(args["val"], ",")
    path = args["p"]
end