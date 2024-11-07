const settings_folder = joinpath(ENV["HOME"], ".Vampires")
const settings_file = joinpath(settings_folder, "settings")

"""
    read_settings!(args)

Reads key-value pairs from a settings file and updates the `args` dictionary with these values.

If `settings_file` exists, each line is read, split by the `=` character, and the resulting key-value pairs 
are stored in the `args` dictionary. The function modifies `args` in-place.

# Arguments
- `args::Dict{String, Any}`: A dictionary to store the parsed settings from the file.
"""
function read_settings!(args)
    if isfile(settings_file)
        for line in eachline(settings_file)
            key, value = string.(split_line(line, char='='))
            args[key] = value
        end
    end
end

"""
    write_settings(keys::Vector{String}, values::Vector{String})

Appends key-value pairs from `keys` and `values` vectors to a settings file, where each pair is written in `key=value` format.

# Arguments
- `keys::Vector{String}`: A vector of keys to be written to the settings file.
- `values::Vector{String}`: A vector of values corresponding to each key in `keys`.
"""
function write_settings(keys::Vector, values::Vector)
    if !isdir(settings_folder); mkdir(settings_folder); end
    remove_setting.(keys)
    open(settings_file, "a") do file
        for (key, value) in zip(keys, values)
            default_args = get_default_args()
            if !haskey(default_args, key)
                error("$key is not found in default keys. Did you spell it correctly?")
            else
                if value == ""
                    error("Value for $key is empty.")
                else
                    println(file, "$key=$value")
                end
            end
        end
    end
end

write_settings(key::AbstractString, value::AbstractString) = write_settings([key], [value])

"""
    remove_setting(key_to_remove::String)

Removes a specific key-value pair from the `settings_file`, where each entry is stored in `key=value` format.

# Arguments
- `key_to_remove::String`: The key whose corresponding entry should be removed from the settings file.
"""
function remove_setting(key_to_remove)
    if isfile(settings_file)
        lines = open_and_read(settings_file)
        rm(settings_file)
        filter!(lines) do line
            key, value = split_line(line, char='=')
            key ≠ key_to_remove
        end
        if length(lines) > 0
            open(settings_file, "w") do file
                println.(file, lines)
            end
        end
    end
end