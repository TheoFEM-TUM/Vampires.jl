"""
list of available tasks:

### recursive wrapper for all tasks:
any_task
    any_subtask: if the option `-r` is specified, the subtask will run in every subfolder of `./`

### recursive wrapper for data extraction tasks
any_task
    any_subtask: if the option `-rcalc` is specified, the calculation  
    
"""


"""
    run_task_recursive(task, subtask, args)

Executes a specified task on all subdirectories of the current directory.

# Arguments
- `task::Function`: The main task function to run.
- `subtask::Function`: The subtask function to run within each folder.
- `args::Dict`: A dictionary of arguments to pass to the `task` function. The path for each subdirectory will be added to this dictionary with the key `"p"`.

# Description
This function scans the current directory for subdirectories. For each subdirectory found, it updates the `args` dictionary with the subdirectory path (under the key `"p"`) and then calls the `task` function with the specified `subtask` and the updated `args`.

The function assumes that the `task` function accepts the `subtask` function and an `args` dictionary as parameters, and that the `args` dictionary should include the path to the current subdirectory.
"""

readfolders(path=".") = filter(entry -> isdir(joinpath(path, entry)), readdir(path))

function run_task(::Type{Val{:r}}, task, subtask, args)
    base_path = args["p"]
    for folder in readfolders(base_path)
        args["p"] =  joinpath(base_path, folder * "/")
        run_task(task, subtask, args)
    end
end


function run_task(::Type{Val{:rconv}}, task, subtask, args)
    collected_value = Float64[]
    base_path = args["p"]
    for folder in readfolders(base_path)
        args["p"] =  joinpath(base_path, folder * "/")
        curr_val = run_task(Val, subtask, args)
        push!(collected_value, run_task(task, subtask, args))
    end
    convergence_plot_value()
end