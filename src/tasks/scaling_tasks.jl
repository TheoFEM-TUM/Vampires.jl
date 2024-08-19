"""
list of available tasks:

strong_scaling
    cpu: create a folder structure with slurm files to analyze CPU scaling in VASP
        example: `strong_scaling cpu --N 1 --ncore 24,24,24,24 --kpar 1,2,3,4 --p ./ --ext_par_file ./extended_parameter_file --block batch_file_cpu`
    gpu: create a folder structure with slurm files to analyze GPU scaling in VASP
        example: `strong_scaling gpu --N 1 --nsim 24,24,24,24 --kpar 1,2,3,4 --p ./ --ext_par_file ./extended_parameter_file --block batch_file_gpu`

weak_scaling
    cpu: create a folder structure with slurm files to analyze weak CPU scaling in VASP
    gpu: create a folder structure with slurm files to analyze weak GPU scaling in VASP
"""


function run_task(task::Union{Type{Val{:strong_scaling}}, Type{Val{:weak_scaling}}}, subtask::Union{Type{Val{:cpu}}, Type{Val{:gpu}}}, args)
    keyword = string(subtask.parameters[1])
    if args["ext_par_file"] == "none"; throw("Tasks preparing slurm scripts require a parameter file."); end
    extended_args = read_config(args["ext_par_file"])[args["block"]]
    kpar_range = [parse(Int, kpar) for kpar in split(args["kpar"], r",|;")]
    ncore_nsim_range = keyword == "cpu" ? args["ncore"] : args["nsim"]
    ncore_nsim_range = [parse(Int, ncore_nsim) for ncore_nsim in split(ncore_nsim_range, r",|;")]
    path = args["p"]
    verbose = args["v"]
    vasp_exe = args["vasp_exe"] == "vasp_std" && haskey(extended_args, "vasp_exe") ? extended_args["vasp_exe"] : args["vasp_exe"]
    time = args["N"] == "none" ? extended_args["time"] : args["N"]
    time = parse(Int, time)
    module_path = extended_args["module_path"]
    module_list = split(extended_args["module_list"], ',')
    partition = extended_args["partition"]
    avail_cpus_per_node = haskey(extended_args, "avail_cpus_per_node") ? parse(Int, extended_args["avail_cpus_per_node"]) : 2
    # default has to be 1 to avoid division by zero error
    avail_gpus_per_node = haskey(extended_args, "avail_gpus_per_node") ? parse(Int, extended_args["avail_gpus_per_node"]) : 1
    omp_num_threads = parse(Int, extended_args["omp_num_threads"])
    mail = extended_args["mail"]
    if task == Val{:strong_scaling}
        strong_scaling_create_subdirectories(kpar_range, ncore_nsim_range; path=path, verbose=verbose, keyword=keyword, time=time,
                                             avail_cpus_per_node=avail_cpus_per_node, avail_gpus_per_node=avail_gpus_per_node,
                                             module_path=module_path, module_list=module_list, vasp_exe=vasp_exe, partition=partition,
                                             omp_num_threads=omp_num_threads, mail=mail)
    elseif task == Val{:weak_scaling}
        super_cell_vector = args["super_cell_vector"] == "none" ? args["val"] : args["super_cell_vector"]
        super_cell_vector = [parse(Int, i) for i in split(super_cell_vector, r",|;")]
        weak_scaling_create_subdirectories(kpar_range, ncore_nsim_range; super_cell_vector, path=path, verbose=verbose, keyword=keyword, time=time,
                                             avail_cpus_per_node=avail_cpus_per_node, avail_gpus_per_node=avail_gpus_per_node,
                                             module_path=module_path, module_list=module_list, vasp_exe=vasp_exe, partition=partition,
                                             omp_num_threads=omp_num_threads, mail=mail)
    end
end


function run_task(::Type{Val{:strong_scaling}}, ::Type{Val{:plot}}, args)
    base_path = args["p"]
    folders = filter(x -> occursin("strong_scaling", x), readfolders(base_path))
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
        plot_strong_scaling_bars(core_n, cpu_avg_time_scf_step_n; type="cpu", title="Strong scaling VASP - CPU", figure_filename="pcpu_lot.png")
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
        plot_strong_scaling_bars(gpu_n, gpu_avg_time_scf_step_n, type="gpu", title="Strong scaling VASP - GPU", figure_filename="gpu_plot.png")
    end
    if length(gpu_folders) > 0 && length(cpu_folders) > 0
        index = parse(Int, args["N"])
        index = index > 0 ? index : 2
        plot_strong_scaling_bars(core_n, cpu_avg_time_scf_step_n, gpu_n, gpu_avg_time_scf_step_n, type="mixed", title="Strong scaling VASP ", figure_filename="gpu_cpu_plot.png", index=index)
    end

end
