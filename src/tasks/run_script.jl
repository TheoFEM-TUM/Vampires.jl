"""
list of available tasks:

run
    make: creates a bash script that runs vasp in a specific folder
"""


"""
# CLI Commands to work with bash scripts

Available commands:
* `vamp run_script make`: Create a bash script to perform VASP calculations.
"""
run_task(::Type{Val{:run}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] run make [--exe <vasp_executable>] [--p <path>] [--exclude <files>]

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
vamp -r run_script make --exe vasp_std

# Example 2: Create a run script to run VASP in all subfolders using the non-collinear vasp executable.
vamp -r run_script make --exe vasp_ncl

# Example 3: Use the `exclude` keyword to specify files to be removed from each subfolder after each calculation.
vamp -r run_script make --exe vasp_std --exclude WAVECAR,CONTCAR,CHGCAR,CHG
```
"""
function run_task(::Type{Val{:run}}, ::Type{Val{:make}}, args)
    cb = get_exclude_callback(args["exclude"])
    write_run_script(args["exe"], args["p"], cb=cb)
end

function run_task_recursive(::Type{Val{:run}}, ::Type{Val{:make}}, args)
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
    partition = haskey(args, "partition") ? args["partition"] : "batch"
    nodes = haskey(args, "nodes") ? args["nodes"] : 1
    time = haskey(args, "time") ? args["time"] : 1
    mail = haskey(args, "mail") ? args["mail"] : ""
    module_list = split_line(haskey(args, "module_list") ? args["module_list"] : "", char=',')
    module_path = haskey(args, "module_path") ? args["module_path"] : ""

    if exe ∉ readdir(args["p"]) && any(occursin.(exe, readdir(args["p"])))
        num_exe = 1
        for file in readdir(args["p"])            
            if occursin(exe, file)
                filename = args["o"] * "_$num_exe"
                write_slurm_script(file, args["p"], filename=filename, partition=partition, nodes=nodes, mail=mail, time=time, module_list=module_list, module_path=module_path)
                num_exe += 1
            end
        end
    else
        write_slurm_script(args["exe"], args["p"], filename=args["o"])
    end
end

"""
    vamp [-r] job submit [--account <account_name>]

Submit all job files that contain the `.job` file ending.

# Arguments
- `r`: if set, submit all job files in all subfolders.
- `account`: the account for which the job is submitted.

# Examples
```bash
# Example 1: Submit all jobs for `MYACCOUNT`.
vamp job submit --account MYACCOUNT

# Example 2: Submit all jobs in all subfolders for `MYACCOUNT`
vamp -r job submit --account MYACCOUNT
```
"""
function run_task(::Type{Val{:job}}, ::Type{Val{:submit}}, args)
    account = args["account"]
    for file in readdir(args["p"])
        if occursin(".job", file)
            run(`sbatch -A $account $file`)
        end
    end
end