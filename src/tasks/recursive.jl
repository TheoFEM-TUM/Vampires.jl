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
    param = args["par"]
    base_path = args["p"]
    values = map(readfolders(base_path)) do folder
        args["p"] = joinpath(base_path, folder * "/")
        value = run_task(task, subtask, args)
        if typeof(value) <: AbstractVector
            if args["method"] == "mean"
                mean_val = mean(value)
                std_val = std(value)
                println("The mean value of $param is: $mean_val ± $std_val.")
            else
                index = parse(Int64, args["N"])
                if index == 0 # The default should be end
                    println("The value in $folder is: ", value[end])
                else
                    println("The value in $folder is: ", value[index])
                end
            end
        end
        value
    end
    if args["method"] == "mean"
        mean_val = mean(values)
        std_val = std(values)
        println("The mean value of $param is: $mean_val ± $std_val.")
    end
    return values
end