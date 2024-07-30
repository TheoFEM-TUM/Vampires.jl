"""
list of available tasks:

### recursive wrapper for all tasks:
any_task
    any_subtask: if the option `-r` is specified, the subtask will run in every subfolder of `./`

"""




readfolders(path=".") = filter(entry -> isdir(joinpath(path, entry)), readdir(path))

"""
    run_task_recursive(task, subtask, args)

Executes a specified task on all subdirectories of the current directory. This serves as default wrapper for any other recursive task.

# Arguments
- `task::Function`: The main task function to run.
- `subtask::Function`: The subtask function to run within each folder.
- `args::Dict`: A dictionary of arguments to pass to the `task` function. The path for each subdirectory will be added to this dictionary with the key `"p"`.

# Description
This function scans the current directory for subdirectories. For each subdirectory found, it updates the `args` dictionary with the subdirectory path (under the key `"p"`) and then calls the `task` function with the specified `subtask` and the updated `args`.

The function assumes that the `task` function accepts the `subtask` function and an `args` dictionary as parameters, and that the `args` dictionary should include the path to the current subdirectory.
"""
function run_task_recursive(task, subtask, args)
    base_path = args["p"]
    for folder in readfolders(base_path)
        args["p"] = joinpath(base_path, folder * "/")
        values = run_task(task, subtask, args)
        if typeof(values) <: AbstractVector
            index = parse(Int64, args["N"])
            #TODO: This is all suboptimal
            if index == 1 # The default should be end
                println("The value in $folder is: ", values[end])
            else
                println("The value in $folder is: ", values[index])
            end
        end
    end
end