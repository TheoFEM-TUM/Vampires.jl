"""
    TASKS

A dictionary that maps task names to their corresponding functions.

# Structure
The `TASKS` dictionary maps string keys (task names) to anonymous functions. Each function takes a single argument `args`, which is a dictionary containing the necessary parameters for the task.

# Tasks
- `"testpar"`: Runs a parameter test.
    - `args["par"]`: Parameter name.
    - `args["val"]`: Comma-separated string of parameter values.
    - `args["p"]`: Path where the test will be executed.
- `"set"`: Sets a keyword in the INCAR file.
    - `args["par"]`: Parameter name.
    - `args["val"]`: Parameter value.
    - `args["p"]`: Path to the INCAR file directory.
    - `args["incar"]`: INCAR file name.
- `"bandgap"`: Computes the bandgap.
    - `args["p"]`: Path to the directory containing the EIGENVAL file.
    - `args["eigenval"]`: EIGENVAL file name.
- `"plot"`: plots the:
    - `bandstructure`
        - `args["p"]`: Path to the directory containing the EIGENVAL file.
        - `args["eigenval"]`: EIGENVAL file name.
        - `args["o"]`: output file name (.png).

        

# Adding New Tasks
To add a new task to the `TASKS` dictionary, follow these steps:

1. Define the task function that takes a single argument `args` (a dictionary of parameters).
2. Add a new entry to the `TASKS` dictionary with the task name as the key and the function as the value.

## Example
Suppose you want to add a task that calculates the total energy from a file. First, define the function:

```julia
function calculate_total_energy(args)
    file_path = args["p"] * args["energyfile"]
    return sum(read_energies(file_path))
end
```

Then, add the new task to the TASKS dictionary:

```julia
TASKS["total_energy"] = (args) -> calculate_total_energy(args)
```

"""
const TASKS = Dict(
    "testpar" => (args) -> run_parameter_test(args["par"], split(args["val"], ","); path=args["p"]),
    "set" => (args) -> set_keyword_in_incar!(args["par"], args["val"], args["p"]*args["input"]),
    # TODO: this should be a calculation task
    "bandgap" => (args) -> run_bandgap_task(args["p"]*args["input"]),
    "plot" => (args) -> run_plot_task(args["p"]*args["input"], args["subtask"], args["o"])
)

"""
    main()

Main function to execute tasks based on command-line arguments.

# Description
This function parses command-line arguments to determine which task to run. It then executes the corresponding task from the `TASKS` dictionary.

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
        task = args["task"]
        
        println("Parsed args:")
        for (arg,val) in args
            println("  $arg  =>  $val")
        end

        if args["p"][end] ≠ '/'; args["p"] *= "/"; end
        
        if task == "none"
            println("Task is none. Exiting ...")
        elseif haskey(TASKS, task)
            println("Running task $task ...")
            TASKS[task](args)
        else
            @error "No task of name $task found."
        end
    end

    println("Time: $time s")
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
            default = ""
        "--par"
            help = "define a parameter that is to be adapted"
            arg_type = String
            default = ""
        "--val"
            help = "define the value of the parameter"
            arg_type = String
            default = ""
        "--p"
            help = "set the default path"
            arg_type = String
            default = "./"
        "--o"
            help = "set the output path"
            arg_type = String
            default = "./output"
        "--incar"
            help = "set the name of the INCAR file"
            arg_type = String
            default = "INCAR"
        "--input"
            help = "set the name of the input file. Depends on Task"
            arg_type = String
            default = "EIGENVAL"
    end
    args :: Dict{String, String} = parse_args(s)
    return args
end

