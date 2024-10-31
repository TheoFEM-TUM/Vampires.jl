# TODO: automatically collect task strings from task files to cli_interface for an overview
"""
    TASKS

Tasks are called using symbols with multiple dispatch


# Adding New Tasks
Any task is defined as
```
function run_task(::Type{Val{:<task>}}, ::Type{Val{:<subtask>}}, args); end
```
`<task>` and `<subtask>` define the task and subtask, respectively.
To add a new task or subtask, define a run_task function in /src/tasks/*.jl.
If there are no task/file for your specific task, create it and add a task
description to the file header. New subtask should also be listed in the header.
"""

"""
    main()

Main function to execute tasks based on command-line arguments.

# Description
This function parses command-line arguments to determine which task to run. It then executes the corresponding task from the `src/tasks` directory using multiple dispatch.
If `-r` is specified, the task will run in every subfolder of the specified directory (default: "./")
# Command-line Arguments
The command-line arguments are parsed into a dictionary `args`.

# Example
To run a task from the command line:
```bash
exec_name bandgap --p=./path/to/files --eigenval=EIGENVAL

"""
function main(cli_args)
    time = @elapsed begin
        args = parse_commandline(cli_args)

        # Read task and subtask parameters
        task = Val{Symbol(args["task"])}
        subtask = Val{Symbol(args["subtask"])}
        verbose = args["v"]

        if verbose
            println("Parsed args:")
            for (arg,val) in args
                println("  $arg  =>  $val")
            end
        end

        if args["p"][end] ≠ '/'; args["p"] *= "/"; end
        if args["help"]
            if args["task"] == "none" && args["subtask"] == "none"
                task_file = joinpath(@__DIR__, "..", "TASKS.md")
                tasks_md = read(task_file, String)
                println("Welcome to")
                println("")
                println("__     ___    __  __ ____ ___ ____  _____")
                println("\\ \\   / / \\  |  \\/  |  _ \\_ _|  _ \\| ____|___")
                println(" \\ \\ / / _ \\ | |\\/| | |_) | || |_) |  _| / __|")
                println("  \\ V / ___ \\| |  | |  __/| ||  _ <| |___\\__ \\")
                println("   \\_/_/   \\_\\_|  |_|_|  |___|_| \\_\\_____|___/")
                println("")
                print(replace(tasks_md, "```\n" => ""))
            else
                println(@doc run_task(::Type{task}, ::Type{subtask}, ::Any))
            end
            return nothing
        end

        try
            task_string = args["task"]
            subtask_string = args["subtask"]
            println("Running task $task_string $subtask_string ...")
            if args["r"]
                run_task_recursive(task, subtask, args)
            else
                run_task(task, subtask, args)
            end
        catch e
            if e == ArgumentError
                @error "No task of name $task found."
            else
                rethrow(e)
            end
        end

    end

    if verbose; println("Time: $time s"); end
end

function get_default_args()
    args_dict = Dict{String, Union{String, Bool}}(
        "task" => "none",
        "subtask" => "none",
        "r" => false,
        "v" => false,
        "help" => false,
        "par"=>"",
        "val"=>"",
        "block"=>"",
        "p"=>"./",
        "o"=>"none",
        "N"=>"0",
        "method"=>"",
        "incar"=>"INCAR",
        "eigenval"=>"EIGENVAL",
        "doscar"=>"DOSCAR",
        "poscar"=>"POSCAR",
        "xdatcar"=>"XDATCAR",
        "outcar"=>"OUTCAR",
        "kpoints"=>"KPOINTS",
        "w90_hr"=>"wannier90_hr.dat",
        "exe"=>"vasp_std"
    )
    return args_dict
end

"""
    parse_commandline(args::Vector{String}) -> Dict{String, Any}

Parses command-line arguments from a vector of strings `args` and returns a dictionary of parsed arguments.

# Arguments
- `args`: A vector of command-line arguments passed as strings.

# Behavior
- Keyword arguments (`--option`): If an argument starts with `--`, it is treated as a key with an associated value in the following position. If a comma is found at the end of an argument, the following arguments are concatenated until no comma is found.
- Flags (`-o`): If an argument starts with a single `-`, it is treated as a flag and is set to `true` (empty "--" arguments are also treated as flags).
- Positional arguments: The first and second arguments that do not start with `--` or `-` are interpreted as `"task"` and `"subtask"` respectively.

# Returns
- `args_dict`: A dictionary containing parsed command-line arguments. Long options are stored as key-value pairs, flags are stored with a value of `true`, and the first two positional arguments are stored as `"task"` and `"subtask"`.
"""
function parse_commandline(args)
    args_dict = get_default_args()
    num_pos = 0
    for (k, arg) in enumerate(args)
        if arg == "-h" || arg == "--help"
            args_dict["help"] = true
        elseif occursin("--", arg)
            new_arg = (length(args) > k && !occursin("-", args[k+1])) ? args[k+1] : true
            j = 0
            while k+j+1 < length(args) && args[k+1+j][end] == ','
                new_arg *= args[k+2+j]
                j += 1
            end

            args_dict[arg[3:end]] = new_arg
        elseif occursin("-", arg)
            args_dict[arg[2:end]] = true
        elseif k == 1 || (k > 1 ? !occursin("--", args[k-1]) : false) || args[k-1] == "--help"
            num_pos += 1
            if num_pos == 1; args_dict["task"] = arg; end
            if num_pos == 2; args_dict["subtask"] = arg; end
        end
    end
    return args_dict
end

run_task(task, subtask, args) = println("Task is none. Exiting ...")