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
                println("********************************************************************************")
                println("* Welcome to                                                                   *")
                println("* __     ___    __  __ ____ ___ ____  _____                                    *")
                println("* \\ \\   / / \\  |  \\/  |  _ \\_ _|  _ \\| ____|___    VASP Analysis               *")
                println("*  \\ \\ / / _ \\ | |\\/| | |_) | || |_) |  _| / __|     for Materials Properties  *")
                println("*   \\ V / ___ \\| |  | |  __/| ||  _ <| |___\\__ \\          In Realistic         *")
                println("*    \\_/_/   \\_\\_|  |_|_|  |___|_| \\_\\_____|___/         Energy Surfaces       *")
                println("*                                                                              *")
                println("********************************************************************************")
                arg_descriptions = get_arg_description()
                println("Positional arguments:")
                for (key, value) in arg_descriptions["posargs"]
                    println("   ", uppercasefirst(key), " : ", value)
                end
                println("")
                delete!(arg_descriptions, "task")
                delete!(arg_descriptions, "subtask")
                println("Optional arguments:")
                for (key, value) in arg_descriptions["optargs"]
                    println("   ", key, " : ", value)
                end
                println("")
                println("get more information by querying specific tasks and subtasks:")
                println("   - vamp --help <task>")
                println("   - vamp --help <task> <subtask>")
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
        "par" => "",
        "val" => "",
        "block" => "",
        "p" => "./",
        "o" => "none",
        "N" => "0",
        "method" => "",
        "incar" => "INCAR",
        "eigenval" => "EIGENVAL",
        "doscar" => "DOSCAR",
        "poscar" => "POSCAR",
        "xdatcar" => "XDATCAR",
        "outcar" => "OUTCAR",
        "kpoints" => "KPOINTS",
        "w90_hr" => "wannier90_hr.dat",
        "vasp_exe" => "vasp_std",
        "exclude" => "none",
        "account" => "none",
        "ext_par_file" => "none",
        "ncore" => "none",
        "nsim" => "none",
        "kpar" => "none",
        "super_cell_vector" => "none",
    )
    return args_dict
end

function get_arg_description()
    arg_descriptions = OrderedDict{String, OrderedDict{String, String}}(
        "posargs" => OrderedDict{String, String}(
            "task" => "positional argument 1: task defines which task is to be performed",
            "subtask" => "positional argument 2: some tasks require further specification"
        ),
        "optargs" => OrderedDict{String, String}(
            "r" => "if true, task will be applied recursively to all folders",
            "v" => "if true, Vampires are verbos",
            "help" => "print help output",
            "par" => "define a parameter that is to be adapted",
            "val" => "define the value of the parameter",
            "block" => "define the block that a parameter belongs to",
            "p" => "set the default path",
            "o" => "set the output (file-) name",
            "N" => "general task dependent number parameter",
            "method" => "general task dependent method parameter",
            "incar" => "set the name of the INCAR file",
            "eigenval" => "set the name of the EIGENVAL file",
            "doscar" => "set the name of the DOSCAR file",
            "poscar" => "set the name of the POSCAR file",
            "xdatcar" => "set the name of the XDATCAR file",
            "outcar" => "set the name of the OUTCAR file",
            "kpoints" => "set the name of the kpoints file",
            "exclude" => "task dependent exclude parameter",
            "regex" => "regular expression that e.g., filters the subdirectories used to run a recursive task",
            "account" => "set the account name for job submission on slurm system",
            "w90_hr" => "set the name of the *_hr.dat file",
            "vasp_exe" => "set the name of the VASP executable",
            "ext_par_file" => "Path to an extended parameter file that contains additional settings for the simulation",
            "ncore" => "Vector of numbers of CPU cores to use for the simulation (scaling tasks only)",
            "nsim" => "Vector of numbers of bands to work on concurrently (scaling tasks only)",
            "kpar" => "Vector of numbers of k-point parallel divisions for the simulation. Determines the parallelization over k-points (scaling tasks only)",
            "super_cell_vector" => "Vector of the first supercell in weak scaling. Nth supercell is then created according to n*super_cell_vector (weak scaling tasks only)"
        )
    )
    return arg_descriptions
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