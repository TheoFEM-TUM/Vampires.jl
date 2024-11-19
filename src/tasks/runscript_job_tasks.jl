"""
list of available tasks:

runscript
    make: creates a bash script that runs vasp in a specific folder
input
    cp: copy all VASP input files to a new folder
job
    make: creates a job script for the given parameters.
    submit: submit all job files
    status: show the status of all active jobs
    cancel: cancel a given job
"""


"""
# CLI Commands to work with bash scripts and jobs (slurm)

Available commands:
* `vamp runscript make`: Create a bash script to perform VASP calculations.
* `vamp job make`: Creates a job script for the given parameters.
* `vamp job submit`: Submits all *.job files.
* `vamp job status`: Shows the status of all active jobs.
* `vamp job cancel`: Cancel a given job
"""
run_task(::Type{Val{:job}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] runscript make [--exe <vasp_executable>] [--p <path>] [--exclude <files>]

Creates a run script that executes the VASP executable at the specified path.

# Arguments
- `exe`: The name of the VASP executable that will be used in the run script.
- `p`: The path where the run script will be created. This is the directory in which the script will be saved.
- `exclude`: File or list of files to be removed after each calculation.

# Behavior
- The function generates a script that runs the VASP executable specified by `vasp_exe`.
- Without a subfolder structure, VASP is only called once. This this task is usually run with the `-r` flag.
- The script is saved in the directory specified by `p`.

# Examples
```bash
# Example 1: Create a run script to run VASP in all subfolders using the standard vasp executable.
vamp -r runscript make --exe vasp_std

# Example 2: Create a run script to run VASP in all subfolders using the non-collinear vasp executable.
vamp -r runscript make --exe vasp_ncl

# Example 3: Use the `exclude` keyword to specify files to be removed from each subfolder after each calculation.
vamp -r runscript make --exe vasp_std --exclude WAVECAR,CONTCAR,CHGCAR,CHG
```
"""
function run_task(::Type{Val{:runscript}}, ::Type{Val{:make}}, args)
    cb = get_exclude_callback(args["exclude"])
    write_run_script(args["exe"], args["p"], cb=cb)
    return nothing
end

function run_task_recursive(::Type{Val{:runscript}}, ::Type{Val{:make}}, args)
    base_path = args["p"]
    cb = get_exclude_callback(args["exclude"])
    nchunks = parse(Int64, args["npar"])
    for (chunk_id, folders) in enumerate(chunks(readfolders(base_path), n=nchunks))
        script_name = nchunks == 1 ? "run_script.sh" : "run_script_$chunk_id.sh"
        for folder in folders
            args["p"] = joinpath(base_path, folder)
            write_run_script(args["exe"], args["p"], cb=cb, out=script_name)
        end
    end
    return nothing
end

"""
    vamp run job make [--exe <executable>] [--partition <partition>] [--nodes <nodes>] [--time <time>]
                      [--mail <email>] [--module_list <modules>] [--module_path <path>] [--p <path>]

Creates and submits a Slurm job script to run the specified executable with customized job settings.

# Arguments
- `exe`: The name of the executable or file to run.
- `partition`: The Slurm partition to use for the job. Defaults to `"batch"`.
- `nodes`: The number of nodes allocated for the job. Defaults to `1`.
- `time`: The maximum runtime for the job, in hours. Defaults to `1`.
- `mail`: An email address for job status notifications.
- `module_list`: A comma-separated list of required modules for the job, loaded before execution.
- `module_path`: A specific module path to load environment modules from.
- `p`: The directory path where the Slurm script will be generated and saved.
- `o`: The output filename prefix for the Slurm script(s).

# Behavior
- Generates a Slurm job script for each executable matching `exe` found in the specified directory.
- If multiple executables match the pattern, unique job scripts are created for each with incremented names.
- If `exe` is found directly, creates and writes a single job script to the path specified by `p`.

# Examples
```bash
# Example 1: Create a job script using the `vasp_std` executable in the specified path.
vamp run job make --exe vasp_std --p /path/to/dir

# Example 2: Generate job scripts for each executable matching "run_file" in the directory, with custom parameters.
vamp run job make --exe run_file --partition short --nodes 2 --time 4 --mail user@example.com --p /path/to/dir --o vasp_job

# Example 3: Load specific modules and specify a module path before running `vasp_std`.
vamp run job make --exe vasp_std --module_list module1,module2 --module_path /path/to/modules --p /path/to/dir
"""
function run_task(::Type{Val{:job}}, ::Type{Val{:make}}, args)
    exe = args["exe"]
    partition = args["partition"]
    nodes = parse(Int64, args["nodes"])
    time = parse(Float64, args["time"])
    mail = args["mail"]
    module_list = split_line(args["module_list"], char=',')
    module_paths = split_line(args["module_paths"], char=',')
    if exe ∉ readdir(args["p"]) && any(occursin.(exe, readdir(args["p"])))
        num_exe = 1
        for file in readdir(args["p"])
            if occursin(exe, file)
                filename = args["o"] * "_$num_exe"
                write_slurm_script(file, args["p"], filename=filename, partition=partition, nodes=nodes, mail=mail, time=time, module_list=module_list, module_paths=module_paths)
                num_exe += 1
            end
        end
    else
        write_slurm_script(exe, args["p"], filename=args["o"], partition=partition, nodes=nodes, mail=mail, time=time, module_list=module_list, module_paths=module_paths)
    end
    return nothing
end

"""
    vamp [-r] job submit [--account <account_name>] [--hostname <hostname>] [--p <path>]

Submit all job files with the `.job` file extension. If the current hostname matches the specified `hostname`, the jobs are submitted locally; otherwise, they are submitted to a remote host.

**Note:** Remote submission requires ssh to be configured such that `ssh <hostname>` establishes a connection to the host. Furthermore, an environment variable `\$SCRATCH_<account_name>` needs to be defined and point to a directory that is accessible on both the local and remote systems.
The paths have to look something like `~/sshfs/<hostname>/path/to/job` (local) and `\$SCRATCH_<account_name>/path/to/job` (remote).

# Arguments
- `r`: if set, submit all `.job` files in all subdirectories.
- `account`: specifies the account to which the job submission is charged.
- `hostname`: optional, specifies the target hostname for the job submission.
- `p`: the directory path where `.job` files are located. If not provided, the current directory is used.

# Examples
```bash
# Example 1: Submit all `.job` files in the current directory for `MYACCOUNT`.
vamp job submit --account MYACCOUNT

# Example 2: Submit all `.job` files in all subdirectories for `MYACCOUNT`.
vamp -r job submit --account MYACCOUNT

# Example 3: Submit `.job` files on a specific host and in a specific directory.
vamp job submit --account MYACCOUNT --hostname target_host
"""
function run_task(::Type{Val{:job}}, ::Type{Val{:submit}}, args)
    account = args["account"]
    hostname = args["hostname"]
    current_hostname = readchomp(`hostname`)
    original_working_directory = pwd()
    path = args["p"]

    cd(path)
    if hostname == "none" || occursin(hostname, current_hostname)
        run(`sbatch -A $account \*.job`)
    else
        scratch_path = "\$SCRATCH_$account/\$USER/"
        path_on_host = split_path_at_folder(pwd(), hostname)
        total_path = joinpath(scratch_path, path_on_host)
        run(`ssh $hostname "cd $total_path && echo \"Submitting job at \$(pwd)\" && sbatch -A $account *.job"`)
    end
    cd(original_working_directory)
    return nothing
end

"""
    vamp job status [--hostname <hostname>]

Check the status of all jobs for the current user. If the current hostname matches the specified `hostname`, the job status is queried locally; otherwise, it is queried on the specified remote host.

**Note:** Remote status queries require SSH to be configured such that `ssh <hostname>` establishes a connection to the remote host.

# Arguments
- `hostname`: Optional, specifies the target hostname to query the job status. If not provided or set to `"none"`, the query runs on the local host.

# Examples
```bash
# Example 1: Check the status of all jobs for the current user on the local host.
vamp job status

# Example 2: Check the status of all jobs for the current user on a remote host `target_host`.
vamp job status --hostname target_host
"""
function run_task(::Type{Val{:job}}, ::Type{Val{:status}}, args)
    hostname = args["hostname"]
    current_hostname = readchomp(`hostname`)

    if hostname == "none" || occursin(hostname, current_hostname)
        run(`squeue -u \$USER -o \"%.18i %.9P %.40j %.8u %.2t %.10M %.6D %R %.9S\"`)
    else
        run(`ssh $hostname "squeue -u \$USER -o \"%.18i %.9P %.40j %.8u %.2t %.10M %.6D %R %.9S\""`)
    end
    return nothing
end

"""
    vamp job cancel [--hostname <hostname>] [--N <job_id>]

Cancel a job with the specified `job_id`. If the current hostname matches the specified `hostname`, the job is cancelled locally; otherwise, it is cancelled remotely on the specified host.

# Arguments
- `hostname`: optional, the target hostname where the job is running. If set to `"none"`, the job is cancelled on the local machine.
- `N`: the job ID of the job to cancel.

# Examples
```bash
# Example 1: Cancel a job with job ID 12345 on the local machine.
vamp job cancel --N 12345

# Example 2: Cancel a job with job ID 12345 on a remote host.
vamp job cancel --hostname remote_host --N 12345
"""
function run_task(::Type{Val{:job}}, ::Type{Val{:cancel}}, args)
    hostname = args["hostname"]
    current_hostname = readchomp(`hostname`)
    job_id = args["N"]

    if hostname == "none" || occursin(hostname, current_hostname)
        run(`scancel $job_id`)
    else
        run(`ssh $hostname "scancel $job_id"`)
    end
    return nothing
end

"""
    vamp [-r] input cp [--p <origin>] [--o <dest>] [--include <additional_files>] [--exclude <file_to_exlude>]

Copy all input files (`POSCAR`, `POTCAR`, `INCAR`, `KPOINTS` by default) to the destination `dest`. If `dest` does not exist, create it. 
Files can be included/excluded using the `include`/`exclude` keywords.

# Arguments
- `p`: Origin path of where to look for the files.
- `o`: Destination path of where to copy files.
- `include`: Additional files to copied.
- `exclude`: Files to exclude.

# Examples
```bash
# Example 1: Copy all VASP inputs to a new folder `MYFOLDER`.
vamp input cp --o MYFOLDER

# Example 2: Copy all files but the `KPOINTS` file and include `myfile`.
vamp input cp --o MYFOLDER --exclude KPOINTS --include myfile
```
"""
function run_task(::Type{Val{:input}}, ::Type{Val{:cp}}, args)
    path = args["p"]
    target = args["o"]
    if target ∉ readdir(); mkdir(target); end
    ignore = split_line(args["exclude"], char=',')
    include = get_include(split_line(args["include"], char=','))
    copy_vasp_input(path, target, ignore=ignore, include=include)
end

"""
    vamp [-r] output rm [--p <path>] [--include <files_to_include>] [--exclude <files_to_exclude>]

Removes selected VASP output files in the specified directory.

# Arguments
- `p`: Path to the directory containing files to be removed. Defaults to the current directory if not provided.
- `include`: (Optional) A comma-separated list of additional files (or file patterns) to include in the deletion, beyond the default VASP outputs.
- `exclude`: (Optional) A comma-separated list of files (or file patterns) to exclude from deletion, even if they match the default VASP outputs or `--include` list.

# Examples
```bash
# Example 1: Remove all VASP output files in `MYFOLDER`
vamp output rm --p MYFOLDER

# Example 2: Remove all VASP output files but EIGENVAL,DOSCAR
vamp output rm --exclude EIGENVAL,DOSCAR
```
"""
function run_task(::Type{Val{:output}}, ::Type{Val{:rm}}, args)
    vasp_outputs = ["CHG", "CHGCAR", "CONTCAR", "DOSCAR", "EIGENVAL", "IBZKPT", "OUTCAR", "PCDAT", "XDATCAR", "WAVECAR", "REPORT", "OSZICAR", "vasp.log", "vasprun.xml", "vaspout.h5", "wannier90.amn", "wannier90.chk", "wannier90.eig", "wannier90.mmn", "wannier90_wsvec.dat"]
    exclude = split_line(args["exclude"], char=',')
    include = split_line(args["include"], char=',')
    for file in readdir(args["p"])
        if (file ∈ vasp_outputs || any(occursin.(file, include))) && !any(occursin.(file, exclude))
            rm(joinpath(args["p"], file), force=true)
        end
    end
end