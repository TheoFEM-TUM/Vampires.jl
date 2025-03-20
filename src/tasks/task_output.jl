""""""

# wrapper functions for task output


"""
    task_output(keys, values, args)

Processes and outputs data from a `read` task based on a specified method, handling recursive operations, broadcasting, and error reporting.

# Parameters
- `out`: A NamedTuple that associates a parameter `key` with an AbstractArray of values.
- `args`: A dictionary of arguments with the following expected keys:
  - `"o"`: The output file path where results will be written.
  - `"reduce"`: A string specifying the processing method. If the last character is `"."`, broadcasting is applied to the method.
  - `"r"`: A boolean flag indicating whether to apply recursive processing.
  - `"v"`: A boolean flag to enable verbose output.
"""
function task_output(out, args)
    output_file = args["o"]
    method = args["reduce"]
    broadcasted = method[end] == '.' ? Val{Symbol("broadcasted")} : nothing
    method = strip(method, '.')
    out_reduced = reduce_output(out, Val{Symbol(method)}, broadcasted)
    time = @elapsed write_output(output_file, out_reduced)
    if args["v"]
        println("Wrote output in $time s.")
    end
end

"""
    reduce_output(out, f, broadcasted)

Processes the `keys` and `values` according to the specified function `f` and the configuration options for `method`, `broadcasted`, and `recursive`.

# Arguments
- `out`: A NamedTuple that associates a parameter `key` with an AbstractArray of values.
- `f`: A function to apply to `values`. Must return a tuple `(result, error)` for each value or sub-collection of values.
- `broadcasted`: Indicates if values are broadcasted.

# Returns
- `out_reduced`: The reduced version of `out`.
"""
reduce_output(out, f::Type{Val{:none}}, broadcasted) = out

function reduce_output(out, f, broadcasted)
    out_reduced = mapreduce(merge, pairs(out)) do (key, value)
        calculate(f, key, value, broadcasted)
    end
    return out_reduced
end

"""
    write_output(output_file, keys, values, errors; folder="none")

Writes the output data to a specified file or prints it to the console, based on the file type. If `output_file` has an `.h5` extension, the data is saved in HDF5 format; otherwise, the key-value-error pairs are printed.

# Arguments
- `output_file`: A string specifying the name and path of the file to write the output. If it ends in `.h5`, the data is written in HDF5 format.
- `out`: A named tuple that contains the key, values and errors (depending on method).
- `folder`: (Optional) A string specifying a folder identifier for output organization when printing. Defaults to `"none"`.
"""
function write_output(output_file, out; folder="none")
    if occursin(".h5", output_file)
        write_data_to_hdf5(output_file, string.(keys(out)), values(out))
    else
        for (key, value) in pairs(out)
            if !occursin("error", string(key))
                error = haskey(out, Symbol("$key"*"_error")) ? out[Symbol("$key"*"_error")] : 0.
                print_output(key, value, error=error)
            end
        end
    end
end

"""
    print_output(key, value; folder="none", error=0.)

Prints a formatted output message displaying the `key`, `value`, optional `folder`, and optional `error` associated with a given value.

# Arguments
- `key`: A string representing the name or label associated with the `value`.
- `value`: The value to be displayed alongside the `key`.
- `folder`: (Optional) A string specifying a folder or grouping identifier. Defaults to `"none"`, which omits folder information from the message.
- `error` (Optional) Specifies the error of `value`, only printed if not zero.
"""
function print_output(key, value; folder="none", error=0., digits=8)
    rounded_value = round_value(value, digits=digits)
    out = "The value for $key "
    if folder ≠ "none"; out *= "in $folder "; end
    out *= "is: $rounded_value"
    if error ≠ 0.; out *= " ± $error"; end
    out *= "."
    println(out)
end

"""
    round_value(value; digits=7)

Rounds a given value or array of values to the specified number of decimal places (default is 7).

# Arguments
- `value`: The value or array of values to be rounded.
- `digits`: The number of digits to round to. Default is 7.

# Returns
- The rounded value, which can be a scalar or an array, depending on the input type.
"""
round_value(value::Number; digits=8) = round(value, digits=digits)
round_value(value::AbstractArray{<:Number}; digits=8) = round.(value, digits=digits)
round_value(value; digits=8) = value