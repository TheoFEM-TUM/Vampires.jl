"""
    get_command_from_cli_args(cli_args::Vector{String}) -> String

Constructs a shell command string from a list of CLI arguments.

This function takes a vector of command-line arguments, strips formatting artifacts
(e.g., quotes, brackets, commas), and prepends the command with `"vamp"`.

# Arguments
- `cli_args::Vector{String}`: A list of command-line arguments.

# Returns
- `String`: A cleaned-up command string ready to be logged or executed.
"""
function get_command_from_cli_args(cli_args)
    command = string(cli_args)
    command = replace(command, "\""=>"", "["=>"", "]"=>"", ","=>"", "Any"=>"")
    command = "vamp $command"
    return command
end

"""
    write_command_to_logfile(command::String, args::Dict{String, String}; filename::String = "vampires.log")

Appends a command string to a log file, with a timestamp and user information.

The logging behavior depends on the `args["log"]` setting:
- `"none"`: No logging is performed.
- `"local"`: Logs to the specified `filename` in the current working directory.
- `"global"`: Logs to the `filename` insid `settings_folder` directory (HOME/.Vampires).

# Arguments
- `command::String`: The command string to log.
- `args::Dict{String, String}`: A dictionary containing all arguments. Must include a `"log"` key.
- `filename::String` (optional): The name of the log file. Defaults to `"vampires.log"`.
"""
function write_command_to_logfile(command, args; filename="vampires.log")
    log_mode = args["log"]
    if log_mode ≠ "none"
        logfile = log_mode == "local" ? filename : joinpath(settings_folder, filename)
        open(logfile, "a") do file
            timestamp = Dates.format(now(), "yyyy-mm-dd HH:MM:SS")
            if log_mode == "local"
                println(file, "$command [$(ENV["USER"]) at $timestamp]")
            elseif log_mode == "global"
                println(file, "$command [$(ENV["USER"]) at $timestamp in $(pwd())]")
            end
        end
    end
end