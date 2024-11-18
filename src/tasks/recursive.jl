"""
list of available tasks:

### recursive wrapper for all tasks:
any_task
    any_subtask: if the option `-r` is specified, the subtask will run in every subfolder of `./`

"""

"""
    readfolders(path=".")

Returns a list of folder names in the specified directory.

# Arguments
- `path::AbstractString`: The directory path to search. Defaults to the current directory (`"."`).

# Returns
- `Vector{String}`: A vector containing the names of subdirectories in the given path.
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
    out = map(readfolders(base_path)) do folder
        args["p"] = joinpath(base_path, folder)
        run_task(task, subtask, args)
    end
    args["p"] = base_path
    if out[1] ≠ nothing
        out_keys = keys(out[1])
        out_values = map(out_keys) do key
            _concat_values([pair[key] for pair in out])
        end
        return NamedTuple(zip(out_keys, out_values))
    else
        return nothing
    end
end