    """
    list of available tasks:


    strong_scaling:
        read: read the results of a strong scaling run
        plot: plot the results of a strong scaling run as a bar plot
        cpu: create a folder structure with slurm files to analyze CPU scaling in VASP
        gpu: create a folder structure with slurm files to analyze GPU scaling in VASP
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


    """
        vamp [-r] strong_scaling <subtask> --ext_par_file <file> --block <name> --kpar <values> [--ncore <values>] [--nsim <values>]
            [--p <path>] [--v <verbose>] [--exe <vasp_exe>] [--N <time>] [--partition <partition>]
            [--omp_num_threads <num>] [--mail <email>]

    Prepares and runs strong scaling tests for VASP simulations, generating necessary directories, input files, and SLURM scripts.

    # Arguments
    - `subtask`: Specifies whether the scaling test is for `"cpu"` or `"gpu"`.
    - `ext_par_file`: Path to an extended parameter file containing additional configuration settings.
    - `block`: The specific block within the extended parameter file to use for configuration.
    - `kpar`: A comma- or semicolon-separated list of `KPAR` values to be tested.
    - `ncore`: (Required for `cpu` tasks) A comma- or semicolon-separated list of `NCORE` values to be tested.
    - `nsim`: (Required for `gpu` tasks) A comma- or semicolon-separated list of `NSIM` values to be tested.
    - `p`: (Optional) The base directory where the scaling tests will be created.
    - `v`: (Optional) Enables verbose output if set.
    - `exe`: (Optional) Specifies the VASP executable to use. Defaults to `"vasp_std"` unless overridden in `ext_par_file`.
    - `N`: (Required as argument or in ext_par_file) Time limit for the SLURM job script. Defaults to the value in `ext_par_file`.
    - `partition`: (Required as argument or in ext_par_file) The SLURM partition to use for the job.
    - `omp_num_threads`: (Required as argument or in ext_par_file) Number of OpenMP threads to use. Defaults to the value in `ext_par_file`.
    - `mail`: (Optional) Email for SLURM job notifications.

    # Throws
    - `Error`: If required arguments (`ext_par_file`, `block`, `kpar`, `ncore/nsim`) are missing.

    # Examples
    ```bash
    # Example 1: Run strong scaling tests for CPUs
    `vamp strong_scaling cpu --N 1 --ncore 24,24,24,24 --kpar 1,2,3,4 --p ./ --ext_par_file /path/to/extended_parameter_file --block batch_file_cpu`

    # Example 2: Run strong scaling tests for GPUs
    `vamp strong_scaling gpu --N 1 --nsim 24,24,24,24 --kpar 1,2,3,4 --p ./ --ext_par_file /path/to/extended_parameter_file --block batch_file_gpu`

    The extended parameter file has the following contents
    ```
    begin batch_file_gpu
        module_paths = /path/to/cpu_modules/
        module_list  = module1,module2
        exe = vasp_std
        partition = gpus
        mail = user.name@mail.com
        omp_num_threads = 40
        avail_gpus_per_node = 2
        avail_gpus_per_node = 4
    end

    begin batch_file_cpu
        module_paths = /path/to/gpu_modules/,
        module_list = module1, module2
        exe = vasp_std
        partition = batch
        mail = user.name@mail.com
        omp_num_threads = 1
        avail_gpus_per_node = 2
    end
    ```
    """
    function run_task(::Type{Val{:strong_scaling}}, subtask::Union{Type{Val{:cpu}}, Type{Val{:gpu}}}, args)
        keyword = string(subtask.parameters[1])
        if (args["ext_par_file"] == "none" || args["block"] == "none")
            println("Error: Tasks preparing slurm scripts for strong scaling requires a parameter file and a specification of the input block. For examples check out `/test/test_files/extended_parameter_file`."); return;
        end
        if (args["kpar"] == "none" || ((args["nsim"] == "none" && keyword == "gpu") || (args["ncore"] == "none" && keyword == "cpu")))
            println("Error: You need to specify `--kpar`, and `--ncore` (for CPU) or `--nsim` (for GPU)."); return;
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


    """
        vamp [-r] strong_scaling read [--p <path>] [--outcar <filename>] [--exclude <pattern>] [--N <index>]

    Reads and processes VASP strong scaling test results from OUTCAR files, extracting the average self-consistent field (SCF) step times.

    # Arguments
    - `p`: (Optional) The base directory where the strong scaling test folders are located.
    - `outcar`: (Optional) The filename of the `OUTCAR` file to read within each test folder.
    - `exclude`: (Optional) A pattern to exclude certain directories from processing.
    - `N`: (Optional) Index for filtering combined CPU/GPU results. If omitted or ≤0, defaults to `2`.

    # Returns
    - If CPU results are found: `(core_n, cpu_avg_time_scf_step_n)`, where:
    - `core_n`: Number of CPU cores used.
    - `cpu_avg_time_scf_step_n`: Corresponding average SCF step time.
    - If GPU results are found: `(gpu_n, gpu_avg_time_scf_step_n)`, where:
    - `gpu_n`: Number of GPUs used.
    - `gpu_avg_time_scf_step_n`: Corresponding average SCF step time.
    - If both CPU and GPU results exist: `(core_n, cpu_avg_time_scf_step_n, gpu_n, gpu_avg_time_scf_step_n)`.
    """
    function run_task(::Type{Val{:strong_scaling}}, ::Type{Val{:read}}, args)
        base_path = args["p"]
        outcar_name = args["outcar"]
        folders = filter(x -> occursin("strong_scaling", x), readfolders(base_path))
        if (args["exclude"] != "none" && args["exclude"] != "")
            folders = filter(x -> !occursin(args["exclude"], x), folders)
        end
        cpu_folders = sort(filter(x -> occursin("_cpu", x), folders))
        gpu_folders = sort(filter(x -> occursin("_gpu", x), folders))
        if length(cpu_folders) > 0
            core_n = []
            cpu_avg_time_scf_step_n = []
            for folder in cpu_folders
                outcar_path = joinpath(base_path, folder, outcar_name)
                loops = read_value_from_outcar("LOOP", outcar_path; type=Float64, line_mode="first")
                push!(cpu_avg_time_scf_step_n, mean(loops))
                cores = parse(Int, split(folder, "_")[3])
                push!(core_n, cores)
            end
        end
        if length(gpu_folders) > 0
            gpu_n = []
            gpu_avg_time_scf_step_n = []
            for folder in gpu_folders
                outcar_path = joinpath(base_path, folder, outcar_name)
                loops = read_value_from_outcar("LOOP", outcar_path; type=Float64, line_mode="first")
                push!(gpu_avg_time_scf_step_n, mean(loops))
                gpus = parse(Int, split(folder, "_")[3])
                push!(gpu_n, gpus)
            end
        end
        if length(cpu_folders) > 0 && length(gpu_folders) > 0
            return (core_n = core_n, time_n = cpu_avg_time_scf_step_n, gpu_m = gpu_n, time_m = gpu_avg_time_scf_step_n)
        elseif length(cpu_folders) > 0
            return (core_n = core_n, time_n = cpu_avg_time_scf_step_n)
        elseif length(gpu_folders) > 0
            return (gpu_m = gpu_n, time_m = gpu_avg_time_scf_step_n)
        end
    end


    """
        vamp strong_scaling plot [--p <path>] [--outcar <filename>] [--N <index>]

    Reads VASP strong scaling test results and generates a bar plot to visualize the speedup in SCF step time.

    # Arguments
    - `"p"`: (Optional) Base path where the results are stored.
    - `"outcar"`: (Optional) The name of the OUTCAR file used to extract time-per-SCF-step data.
    - `"N"`: (Optional) Specifies the running index of the CPU comparison for mixed CPU-GPU plots.

    # Output
    - The function generates a bar plot visualizing the speedup for the selected scaling test:
    - `"cpu_plot.png"` for CPU scaling.
    - `"gpu_plot.png"` for GPU scaling.
    - `"gpu_cpu_plot.png"` for mixed CPU-GPU scaling.
    """
    function run_task(::Type{Val{:strong_scaling}}, ::Type{Val{:plot}}, args)
        scaling_results = run_task(Val{Symbol("strong_scaling")}, Val{Symbol("read")}, args)
        if haskey(scaling_results, :gpu_m) && haskey(scaling_results, :core_n)
            if (args["N"] == "none"); println("For mixed CPU and GPU plots, please use `--N` to specify the running index of the CPU comparison you want to show."); exit(); end
            index = parse(Int, args["N"])
            index = index > 0 ? index : 2
            plot_strong_scaling_bars(scaling_results.core_n, scaling_results.time_n, scaling_results.gpu_m, scaling_results.time_m, type="mixed", title="Strong scaling VASP ", figure_filename="gpu_cpu_plot.png", index=index)
        elseif haskey(scaling_results, :core_n)
            plot_strong_scaling_bars(scaling_results.core_n, scaling_results.time_n; type="cpu", title="Strong scaling VASP - CPU", figure_filename="cpu_plot.png")
        else
            plot_strong_scaling_bars(scaling_results.gpu_m, scaling_results.time_m; type="gpu", title="Strong scaling VASP - GPU", figure_filename="gpu_plot.png")
        end
    end