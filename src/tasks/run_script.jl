"""
list of available tasks:

run_script
    make: creates a bash script that runs vasp in a specific folder
"""


"""
# CLI Commands to work with bash scripts

Available commands:
* `vamp run_script make`: Create a bash script to perform VASP calculations.
"""
run_task(::Type{Val{:run_script}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] run_script make [--vasp_exe <vasp_executable>] [--p <path>]

Creates a run script that executes the VASP executable at the specified path.

# Arguments
- `vasp_exe`: The name of the VASP executable that will be used in the run script.
- `p`: The path where the run script will be created. This is the directory in which the script will be saved.

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
function run_task(::Type{Val{:run_script}}, ::Type{Val{:make}}, args)
    cb = get_exclude_callback(args["exclude"])
    write_run_script(args["exe"], args["p"], cb=cb)
end

function run_task_recursive(::Type{Val{:run_script}}, ::Type{Val{:make}}, args)
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