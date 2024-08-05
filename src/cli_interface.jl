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
function main()
    time = @elapsed begin
        @time args = parse_commandline()
        
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

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "task"
            help = "positional argument 1: task defines which task is to be performed"
            arg_type = String
            default = "none"
        "subtask"
            help = "positional argument 2: some tasks require further specification"
            arg_type = String
            default = "none"
        "-r"
            help = "if true, task will be applied recursively to all folders"
            action = :store_true
        "-v"
            help = "if true, Vampires are verbose."
            action = :store_true
        "--par"
            help = "define a parameter that is to be adapted"
            arg_type = String
            default = ""
        "--val"
            help = "define the value of the parameter"
            arg_type = String
            default = ""
        "--block"
            help = "define the block that a parameter belongs to"
            arg_type = String
            default = ""
        "--p"
            help = "set the default path"
            arg_type = String
            default = "./"
        "--o"
            help = "set the output (file-) name"
            arg_type = String
            default = "none"
        "--N"
            help = "general task dependent number parameter"
            arg_type = String
            default = "0"
        "--m"
            help = "general task dependent method parameter"
            arg_type = String
            default = "none"
        "--incar"
            help = "set the name of the INCAR file"
            arg_type = String
            default = "INCAR"
        "--eigenval"
            help = "set the name of the EIGENVAL file"
            arg_type = String
            default = "EIGENVAL"
        "--doscar"
            help = "set the name of the DOSCAR file"
            arg_type = String
            default = "DOSCAR"
        "--poscar"
            help = "set the name of the POSCAR file"
            arg_type = String
            default = "POSCAR"
        "--xdatcar"
            help = "set the name of the XDATCAR file"
            arg_type = String
            default = "XDATCAR"
        "--outcar"
            help = "set the name of the OUTCAR file"
            arg_type = String
            default = "OUTCAR"
        "--kpoints"
            help = "set the name of the kpoints file"
            arg_type = String
            default = "KPOINTS"
        "--vasp_exe"
            help = "set the name of the VASP executable"
            arg_type = String
            default = "vasp_std"
    end
    args :: Dict{String, Union{String, Bool}} = parse_args(s)
    return args
end

run_task(task, subtask, args) = println("Task is none. Exiting ...")