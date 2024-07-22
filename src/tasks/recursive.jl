function run_task_recursive(::Type{Val{:plot}}, ::Type{Val{:bandstructure}}, args)
    all_entries = readdir()

    # Filter all non-folders
    only_folders = filter(entry -> isdir(joinpath(".", entry)), all_entries) .* "/"
    for folder in only_folders
        args["p"] = joinpath(".", folder)
        run_task(Val{Symbol(args["task"])}, Val{Symbol(args["subtask"])}, args)
    end
end