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
function run_task_recursive(task, subtask, args)
    all_entries = readdir()

    # Filter all non-folders
    only_folders = filter(entry -> isdir(joinpath(".", entry)), all_entries) .* "/"
    for folder in only_folders
        args["p"] = joinpath(".", folder)
        run_task(task, subtask, args)
    end
end