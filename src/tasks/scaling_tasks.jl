"""
list of available tasks:


strong_scaling:
    read: read the results of a strong scaling run
    plot: plot the results of a strong scaling run as a bar plot
    cpu: create a folder structure with slurm files to analyze CPU scaling in VASP
        example: `strong_scaling cpu --N 1 --ncore 24,24,24,24 --kpar 1,2,3,4 --p ./ --ext_par_file /path/to/extended_parameter_file --block batch_file_cpu`
    gpu: create a folder structure with slurm files to analyze GPU scaling in VASP
        example: `strong_scaling gpu --N 1 --nsim 24,24,24,24 --kpar 1,2,3,4 --p ./ --ext_par_file /path/to/extended_parameter_file --block batch_file_gpu`

"""


"""
# CLI Commands to conduct and analyze strong scaling experiments

Available commands:
* `vamp strong_scaling read: read the results of a strong scaling run
* `vamp strong_scaling plot`: plot the results of a strong scaling run as bar plot
* `vamp strong_scaling cpu`: create a folder structure with slurm files to analyze CPU scaling in VASP
* `vamp strong_scaling gpu`: create a folder structure with slurm files to analyze GPU scaling in VASP

"""
run_task(::Type{Val{:strong_scaling}}, ::Type{Val{:none}}, args) = nothing


function run_task(::Type{Val{:strong_scaling}}, subtask::Union{Type{Val{:cpu}}, Type{Val{:gpu}}}, args)
    keyword = string(subtask.parameters[1])
    if (args["ext_par_file"] == "none" || args["block"]) == "none"
        println("Error: Tasks preparing slurm scripts for strong scaling requires a parameter file and a specification of the input block. For examples check out `/test/test_files/extended_parameter_file`."); exit;
    end
    if (args["kpar"] == "none" || ((args["nsim"] == "none" && keyword == "gpu") || (args["ncore"] == "none" && keyword == "cpu")))
        println("Error: You need to specify `--kpar`, and `--ncore` (for CPU) or `--nsim` (for GPU)."); exit();
    end
    extended_args = read_config(args["ext_par_file"])[args["block"]]
    kpar_range = [parse(Int, kpar) for kpar in split(args["kpar"], r",|;")]
    ncore_nsim_range = keyword == "cpu" ? args["ncore"] : args["nsim"]
    ncore_nsim_range = [parse(Int, ncore_nsim) for ncore_nsim in split(ncore_nsim_range, r",|;")]
    path = args["p"]
    verbose = args["v"]
    vasp_exe = args["exe"] == "vasp_std" && haskey(extended_args, "exe") ? extended_args["exe"] : args["exe"]
    time = args["N"] == "none" ? extended_args["time"] : args["N"]
    time = parse(Int, time)
    module_paths = split(extended_args["module_paths"], r",|;")
    module_list = split(extended_args["module_list"], r",|;")
    partition = extended_args["partition"]
    avail_cpus_per_node = haskey(extended_args, "avail_cpus_per_node") ? parse(Int, extended_args["avail_cpus_per_node"]) : 2
    # default has to be 1 to avoid division by zero error
    avail_gpus_per_node = haskey(extended_args, "avail_gpus_per_node") ? parse(Int, extended_args["avail_gpus_per_node"]) : 1
    omp_num_threads = parse(Int, extended_args["omp_num_threads"])
    mail = extended_args["mail"]
    strong_scaling_create_subdirectories_VASP(kpar_range, ncore_nsim_range; path=path, verbose=verbose, keyword=keyword, time=time,
                                         avail_cpus_per_node=avail_cpus_per_node, avail_gpus_per_node=avail_gpus_per_node,
                                         module_paths=module_paths, module_list=module_list, exe=vasp_exe, partition=partition,
                                         omp_num_threads=omp_num_threads, mail=mail)
end


function run_task(::Type{Val{:strong_scaling}}, ::Type{Val{:read}}, args)
    base_path = args["p"]
    folders = filter(x -> occursin("strong_scaling", x), readfolders(base_path))
    if args["exclude"] != "none"
        folders = filter(x -> !occursin(args["exclude"], x), folders)
    end
    cpu_folders = sort(filter(x -> occursin("_core", x), folders))
    gpu_folders = sort(filter(x -> occursin("_gpu", x), folders))
    outcar_name = args["outcar"]
    if length(cpu_folders) > 0
        core_n = []
        cpu_avg_time_scf_step_n = []
        for folder in cpu_folders
            outcar_path = base_path*folder*"/"*outcar_name
            loops = read_value_from_outcar("LOOP", outcar_path; type=Float64, line_mode="first")
            push!(cpu_avg_time_scf_step_n, mean(loops))
            cores = parse(Int, split(folder, "_")[3])
            push!(core_n, cores)
        end
        return core_n, cpu_avg_time_scf_step_n
    end
    if length(gpu_folders) > 0
        gpu_n = []
        gpu_avg_time_scf_step_n = []
        for folder in gpu_folders
            outcar_path = base_path*folder*"/"*outcar_name
            loops = read_value_from_outcar("LOOP", outcar_path; type=Float64, line_mode="first")
            push!(gpu_avg_time_scf_step_n, mean(loops))
            gpus = parse(Int, split(folder, "_")[3])
            push!(gpu_n, gpus)
        end
        return gpu_n, gpu_avg_time_scf_step_n
    end
    if length(gpu_folders) > 0 && length(cpu_folders) > 0
        index = parse(Int, args["N"])
        index = index > 0 ? index : 2
        return core_n, cpu_avg_time_scf_step_n, gpu_n, gpu_avg_time_scf_step_n
    end

end