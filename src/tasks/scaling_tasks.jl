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