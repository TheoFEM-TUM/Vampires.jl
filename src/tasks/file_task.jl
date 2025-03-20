"""
list of available tasks:


h5:
    read: call the read task for `file` and create a plot.
"""

"""
# CLI Commands to work with h5 files

Available commands:
* `vamp h5 read`: read the contents of an h5 file
"""
run_task(::Type{Val{:h5}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] h5 read --h5 <file> [--p <path>]

Read the contents of an *.h5 file and return then as a NamedTuple. Useful for plotting.

# Arguments
- `h5`: Name of the h5 file. The extension '.h5' is not required
- `r`: Task is applied recursively to h5 files in all subfolders.
- `p`: Sets the path where the command is executed.

# Examples
```bash
# Example 1: Read an h5 file of FILENAME
vamp h5 read --h5 FILENAME
```
"""
function run_task(::Type{Val{:h5}}, ::Type{Val{:read}}, args)
    filename = occursin(".h5", args["h5"]) ? args["h5"] : args["h5"] * ".h5"
    h5open(joinpath(args["p"], filename), "r") do file
        out = mapreduce(merge, keys(file)) do dataset
            NamedTuple(zip([Symbol(dataset)], [read(file, dataset)]))
        end
        return out
    end
end