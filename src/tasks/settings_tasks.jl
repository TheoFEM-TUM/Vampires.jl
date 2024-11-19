"""
list of available tasks:

settings
    set: set a new setting in the settings file
    rm: remove a setting from the settings file
    read: read a setting from the settings file
"""



"""
# CLI Commands to set/modify default settings

Available commands:
* `vamp settings set`: set a new setting in the settings file.
* `vamp settings rm`: remove a setting from the settings file.
* `vamp settings read`: read a setting from the settings file.
"""
run_task(::Type{Val{:settings}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp settings set --par <key> --val <value>

Change the default value for `key` to `value`.

# Arguments
- `par`: The key for which the default value is set.
- `val`: The new default value.

# Examples
```bash
# Example 1: Change the default for `exe` to `run_file`.
vamp settings set --par exe --val run_file
```
"""
function run_task(::Type{Val{:settings}}, ::Type{Val{:set}}, args)
    keys = split_line(args["par"], char=',')
    values = length(keys) > 1 ? split_line(args["val"], char=',') : [args["val"]]
    write_settings(keys, values)
    return nothing
end

"""
    vamp settings rm --par <key>

Remove the default value for `key`.

# Arguments
- `par`: The key for which the default value is to be removed.

# Examples
```bash
# Example 1: Remove the default for `exe` to `run_file`.
vamp settings rm --par exe
```
"""
function run_task(::Type{Val{:settings}}, ::Type{Val{:rm}}, args)
    keys = split_line(args["par"], char=',')
    remove_setting.(keys)
    return nothing
end

"""
    vamp settings read

Read all settings.

# Examples
```bash
# Example 1: Read all settings.
vamp settings read
```
"""
function run_task(::Type{Val{:settings}}, ::Type{Val{:read}}, args)
    settings = OrderedDict{String, String}()
    read_settings!(settings)
    return NamedTuple(zip(Symbol.keys(settings), values(settings)))
end