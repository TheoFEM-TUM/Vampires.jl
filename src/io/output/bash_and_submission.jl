"""
    write_run_script(vasp_exe, path; out="run_job.sh")

Writes a bash script to run VASP in specified folders. If the script already exists, it adds the new folder path to the `folders` array.

# Arguments
- `vasp_exe::String`: The command to execute the VASP program.
- `path::String`: The path to add to the `folders` array in the script.
- `out::String`: The output file name for the script. Defaults to `"run_job.sh"`.

# Description
This function creates a bash script named `run_job.sh` (or the name specified by `out`). If the file already exists, the function adds the specified `path` to the `folders` array within the existing script. 
If the file does not exist, it creates a new script with the necessary structure to run VASP in each folder specified in the `folders` array.
The script will iterate over each folder in the `folders` array, change to that directory, execute the VASP command, and then return to the parent directory.
"""
function write_run_script(vasp_exe, path; out="run_job.sh", cb="none")
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
            println(runfile, "    srun $vasp_exe  > vasp.log")
            if cb ≠ "none"; println(runfile, "    "*cb); end 
            println(runfile, "    cd ..")
            println(runfile, "done")
        end
    end
    run(`chmod +x $out`)
end


"""
    add_path_to_folders(file::String, new_path::String)

Adds a new path to the `folders` line in a bash script file. Helper function for write_run_script.

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
end


"""
    TODO
"""
function write_slurm_script(path;  module_path="", module_list=[], vasp_exe="vasp_exe", time=1, nodes=1, ntasks=48, ntasks_per_core=1, omp_num_threads=24, num_gpu=0, partition="batch", mail="", script_filename="batch_jobscript")
    out = path*"/"*script_filename
    hrs = trunc(Int, time)
    min = trunc(Int, modf(time)[1]*60)
    sec = trunc(Int, modf(modf(time)[1]*60)[1]*60)
    open(out, "w") do outfile
        print(outfile, """
        #!/bin/bash
        #========================================#
        # batch script for VASP
        #========================================#
        # Batch setup -> system reads # s batch
        ###
        #SBATCH --nodes=$nodes
        #SBATCH -t $hrs:$min:$sec 
        #SBATCH --partition=$partition
        #SBATCH --ntasks=$ntasks
        """)
        if num_gpu > 0
            print(outfile, """
            #SBATCH --gres=gpu:$num_gpu
            # this is required in VASP 6.4.1 - supports only one rank per GPU
            #SBATCH --ntasks-per-node=$num_gpu
            # GPU allocation (VASP specific; necessary?)
            #SBATCH --gpus-per-task=1       # num GPUs per process
            """)
        else
            print(outfile, """
            #SBATCH --ntasks-per-core=$ntasks_per_core
            #SBATCH --partition=$partition
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
        if length(module_path) > 0 || length(module_list) > 0
            print(outfile, """
            #========================================#
            # module setup for VASP
            #========================================#
            """)
        end
        if length(module_path) > 0
            print(outfile, """
            module use $module_path
            """)
        end
        if length(module_list) > 0
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
        echo "Work directory is `pwd`"
        echo "VASP binary at " \$vasp_exe
        
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
        # 5. Systam info
        #========================================#
        hostname > host.info
        grep 'Linux' /etc/issue >> host.info
        grep 'model name' /proc/cpuinfo |cut -d: -f2 |uniq -c >> host.info
        grep 'cpu M' /proc/cpuinfo >> host.info
        grep 'MemTotal' /proc/meminfo >> host.info
        free -g >> host.info
        ulimit -a >> host.info
        echo \$SLURM_NODELIST >> host.info
        echo The VASP version is \${$vasp_exe} >> host.info

        #========================================#
        # 5. VASP run
        #========================================#
        """)
        if num_gpu == 0
            print(outfile, """
            srun \${$vasp_exe} > vasp.log
            """)
        else
            print(outfile, """
            orterun --map-by ppr:$num_gpu:node --bind-to core -np $num_gpu \${$vasp_exe} > vasp.log
            """)
        end
    end
end
