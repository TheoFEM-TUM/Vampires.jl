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
vamp -r run_script make --vasp_exe vasp_std

# Example 2: Create a run script to run VASP in all subfolders using the non-collinear vasp executable.
vamp -r run_script make --vasp_exe vasp_ncl
```
"""
function run_task(::Type{Val{:run_script}}, ::Type{Val{:make}}, args)
    write_run_script(args["vasp_exe"], args["p"])
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