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

function parse_commandline(args)
    args_dict = Dict{String, Union{String, Bool}}(
        "task" => "none",
        "subtask" => "none",
        "r" => false,
        "v" => false,
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
        "vasp_exe"=>"vasp_std"
    )
    num_pos = 0
    for (k, arg) in enumerate(args)
        if occursin("--", arg)
            args_dict[arg[3:end]] = args[k+1]
        elseif occursin("-", arg)
            args_dict[arg[2:end]] = true
        elseif k == 1 || (k > 1 ? !occursin("--", args[k-1]) : false)
            num_pos += 1
            if num_pos == 1; args_dict["task"] = arg; end
            if num_pos == 2; args_dict["subtask"] = arg; end
        end
    end
    return args_dict
end

run_task(task, subtask, args) = println("Task is none. Exiting ...")