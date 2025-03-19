"""
    write_run_script(exe, path; out="run_job.sh")

Writes a bash script to run a command in specified folders. If the script already exists, it adds the new folder path to the `folders` array.

# Arguments
- `exe::String`: The command to execute in each subfolder.
- `path::String`: The path to add to the `folders` array in the script.
- `out::String`: The output file name for the script. Defaults to `"run_job.sh"`.
- `cb::String`: callback function to be executed after the `exe` run in each subdirectory
- `run_out::String`: The output filename for the executed `exe` command

"""
function write_run_script(exe, path; out="run_job.sh", cb="", run_out="vasp.log")
    if out in readdir()
        add_path_to_folders(out, path)
    else
        open(out, "a") do runfile
            println(runfile, "#!/bin/bash")
            if path ≠ "./"
                println(runfile, "folders=(\"$path\")")
            else
                println(runfile, "folders=()")
            end
            println(runfile, "for folder in \"\${folders[@]}\"")
            println(runfile, "do")
            println(runfile, "    cd \$folder")
            if occursin(".sh", exe)
                println(runfile, "    bash $exe > $run_out")
            else
                println(runfile, "    srun $exe  > $run_out")
            end
            if cb ≠ ""; println(runfile, "    "*cb); end
            println(runfile, "    echo \"Calculation in \$folder completed.\"")
            println(runfile, "    cd ..")
            println(runfile, "done")
        end
    end
    run(`chmod +x $out`)
end

"""
    get_exclude_callback(excludes::String) -> String

Generates a command string to remove specified files after a calculation. If the `excludes` argument is non-empty, this function builds a shell command to remove each file listed in `excludes`. File names in `excludes` should be comma-separated.

# Arguments
- `excludes`: A comma-separated string of file names to exclude (i.e., remove) after calculation.

# Returns
- A string representing the shell command to remove the specified files. Returns an empty string if `excludes` is empty.
"""
function get_exclude_callback(excludes)
    cb = ""
    if excludes ≠ ""
        excluded_files = split_line(excludes, char=',')
        cb = "rm" * prod([" "*file for file in excluded_files])
    end
    return cb
end

"""
    add_path_to_folders(file::String, new_path::String)

Adds a new path to the `folders` line in a bash script file.

# Arguments
- `file::String`: The path to the bash script file (`run_job.sh`).
- `new_path::String`: The new path to add to the `folders` line.

# Description
This function reads the specified file line-by-line, looks for the line that defines the `folders` array
(e.g., `folders=("path1" "path2")`), and adds the `new_path` to this array. The line will be modified to
include the new path, and all other lines in the file will remain unchanged. The modified file is written
back to the original file.
"""
function add_path_to_folders(file::String, new_path::String)
    lines = readlines(file)

    target_pattern = r"""folders=\((.*)\)"""

    open(file, "w") do f
        for line in lines
            if occursin(target_pattern, line)
                # Extract the existing paths
                captures = match(target_pattern, line).captures
                existing_paths = captures[1]

                # Add the new path to the list of existing paths
                new_folders_line = "folders=(" * existing_paths * " \"$new_path\")"

                write(f, new_folders_line * "\n")
            else
                write(f, line * "\n")
            end
        end
    end
    return nothing
end

"""
    write_slurm_script(exe, path; module_paths="", module_list=[], time=1, nodes=1, ntasks_per_node=48,
                       ntasks_per_core=1, omp_num_threads=24, num_gpu=0, partition="batch", mail="", filename="batch_jobscript")

Generate a SLURM batch script for running VASP on an HPC system, optimized for JUWELS, but may require adjustments for other HPC systems.

# Arguments
- `exe::String="vasp_std"`: The executable to run.
- `path::String`: The directory where the SLURM script will be created.
- `module_paths::String=""`: Path to the module files if needed.
- `module_list::Vector{String}=[]`: List of modules to load.
- `time::Int=1`: The wall time limit for the SLURM job script (in hours).
- `nodes::Int=1`: The number of nodes to allocate.
- `ntasks_per_node::Int=48`: The total number of tasks per node
- `ntasks_per_core::Int=1`: Number of tasks per core.
- `omp_num_threads::Int=24`: Number of OpenMP threads.
- `num_gpu::Int=0`: The number of GPUs to allocate.
- `partition::String="batch"`: The partition to submit the job to.
- `mail::String=""`: Email address for job notifications.
- `filename::String="job"`: The filename for the SLURM batch script.

# Description
This function generates a SLURM batch script tailored for running VASP simulations. It includes necessary batch setup configurations, module loading commands, and commands for running VASP either on CPU or GPU.

The generated script is optimized for the JUWELS supercomputing system, and might require further adjustments to work on other HPC systems.

# Example
```julia
write_slurm_script("vasp_std",
    "/path/to/dir";
    module_paths="/path/to/modules",
    module_list=["module1", "module2"],
    time=2,
    nodes=2,
    ntasks_per_node=48,
    ntasks_per_core=2,
    omp_num_threads=12,
    num_gpu=4,
    partition="batch",
    mail="user@example.com",
    filename="my_slurm_script.sh"
)
"""
function write_slurm_script(exe, path; module_paths::AbstractArray=[], module_list::AbstractArray=[],
                            time=1, nodes=1, ntasks_per_node=48, ntasks_per_core=1, omp_num_threads=1, num_gpu=0,
                            partition::AbstractString="batch", mail::AbstractString="", filename::AbstractString="job")
    out = path*filename*".job"
    hrs = trunc(Int, time)
    min = trunc(Int, modf(time)[1]*60)
    sec = trunc(Int, modf(modf(time)[1]*60)[1]*60)
    time_str = lpad(hrs, 2, "0")*":"*lpad(sec, 2, "0")*":"*lpad(sec, 2, "0")
    open(out, "w") do outfile
        print(outfile, """
        #!/bin/bash
        #========================================#
        # batch script for VASP
        #========================================#
        # Batch setup -> system reads # s batch
        ###
        #SBATCH --nodes=$nodes
        #SBATCH --time=$time_str
        #SBATCH --partition=$partition
        """)
        if num_gpu == 0
            print(outfile, """
            #SBATCH --ntasks-per-node=$ntasks_per_node
            """)
            if ntasks_per_core ≠ 1
                print(outfile, """
                #SBATCH --ntasks-per-core=$ntasks_per_core
                """)
            end
        else # num_gpu > 0
            print(outfile, """
            #SBATCH --gres=gpu:$num_gpu
            # this is required in VASP 6.4.1 - supports only one rank per GPU
            #SBATCH --ntasks-per-node=$num_gpu
            # GPU allocation (VASP specific; necessary?)
            #SBATCH --gpus-per-task=1       # num GPUs per process
            """)
        end
        print(outfile, """
        #SBATCH --error=ERROR.%j
        """)
        if length(mail) > 0
            print(outfile, """
            #SBATCH --mail-user=$mail
            #SBATCH --mail-type=START,FAIL,END
            """)
        end
        if size(module_paths, 1) > 0 || size(module_list, 1) > 0
            print(outfile, """

            #========================================#
            # module setup for VASP
            #========================================#
            """)
        end
        if size(module_paths, 1) > 0
            for mod_path in module_paths
                print(outfile, """
                module use $mod_path
                """)
            end
        end
        if size(module_list, 1) > 0
            for mod in module_list
                print(outfile, """
                module load $mod
                """)
            end
        end
        print(outfile, """

        # ALL RUNS IN \$WORK !
        # ... better
        # start the jobs inside the correct directory
        # as per default initial directory is the directory
        # from where the job was submitted

        #========================================#
        # 3. Integrity check
        #========================================#

        echo "Starting at `date`"
        echo "Running on hosts: \$SLURM_NODELIST"
        echo "Running on \$SLURM_NNODES nodes."
        echo "Running on \$SLURM_NPROCS processors."
        echo "Work directory is \$(pwd)"
        echo "VASP binary at " \$exe

        echo
        echo "Starting VASP run at" `date`
        echo

        #========================================#
        # 4. Parallel execution
        #========================================#

        export OMP_NUM_THREADS=$omp_num_threads
        # make sure that MKL does not overwrite your OMP configuration
        export MKL_NUM_THREADS=$omp_num_threads
        """)
        if num_gpu > 0
            print(outfile, """
            export MKL_THREADING_LAYER=INTEL
            export OMP_PLACES=cores
            export OMP_PROC_BIND=close
            export OMP_STACKSIZE=512m
            """)
        end
        print(outfile, """

        #========================================#
        # 5. System info
        #========================================#
        hostname > host.info
        grep 'Linux' /etc/issue >> host.info
        grep 'model name' /proc/cpuinfo |cut -d: -f2 |uniq -c >> host.info
        grep 'cpu M' /proc/cpuinfo >> host.info
        grep 'MemTotal' /proc/meminfo >> host.info
        free -g >> host.info
        ulimit -a >> host.info
        echo \$SLURM_NODELIST >> host.info
        echo The VASP version is $exe >> host.info

        #========================================#
        # 5. Main job execution
        #========================================#
        """)
        if num_gpu == 0 && occursin("vasp", exe)
            print(outfile, """
            srun $exe > vasp.log
            """)
        elseif num_gpu == 0 && occursin(".sh", exe)
            print(outfile, """
            bash $exe
            """)
        else
            print(outfile, """
            orterun --map-by ppr:$num_gpu:node --bind-to core -np $num_gpu $exe > vasp.log
            """)
        end
    end
end