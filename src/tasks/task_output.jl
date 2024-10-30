"""
list of available tasks
"""


"""
    task_output(keys, values, args)

Processes and outputs data from a `read` task based on a specified method, handling recursive operations, broadcasting, and error reporting.

# Parameters
- `keys`: A collection of keys associated with each entry in `values`.
- `values`: A collection of values to process and output.
- `args`: A dictionary of arguments with the following expected keys:
  - `"o"`: The output file path where results will be written.
  - `"method"`: A string specifying the processing method. If the last character is `"."`, broadcasting is applied to the method.
  - `"r"`: A boolean flag indicating whether to apply recursive processing.
  - `"v"`: A boolean flag to enable verbose output.
"""
function task_output(keys, values, args)
    output_file = args["o"]
    method = args["method"]
    broadcasted = method[end] == '.' ? Val{Symbol("broadcasted")} : nothing
    recursive = args["r"] ? Val{Symbol("recursive")} : nothing
    method = strip(method, '.')
    f = get_method(method)
    keys_out, values_out, errors = reduce_output(keys, values, f, method, broadcasted, recursive)
    time = @elapsed if args["r"] && (args["method"][end] == '.' || method == "none")
        for (value, error, folder) in zip(values_out, errors, readfolders(args["p"]))
            write_output(output_file, keys_out, value, error, folder=folder)
        end
    else
        write_output(output_file, keys_out, values_out, errors)
    end

    if args["v"]
        println("Wrote output in $time s.")
    end
end

"""
    reduce_output(keys, values, f, method, broadcasted, recursive)

Processes the `keys` and `values` according to the specified function `f` and the configuration options for `method`, `broadcasted`, and `recursive`.

# Arguments
- `keys`: An iterable representing unique keys for the values.
- `values`: A collection of values associated with the `keys`. The structure of `values` depends on the function variant and `recursive` option.
- `f`: A function to apply to `values`. Must return a tuple `(result, error)` for each value or sub-collection of values.
- `method`: A string or identifier specifying the method to be appended to the `keys` when generating `keys_out`.
- `broadcasted`: Indicates if values are broadcasted.
- `recursive`: Specifies if reduction should be applied recursively (for recursive tasks).

# Returns
- `keys_out`: A vector of processed keys, with `method` appended as specified.
- `values_out`: A collection of outputs from applying `f` to each element in `values`, following broadcast or recursion rules as appropriate.
- `errors`: A collection of error values returned by `f` for each processed `value` or sub-collection in `values`.
"""
reduce_output(keys, values, f::Type{Val{:none}}, method, broadcasted, recursive) = keys, values, [zeros(length(keys)) for _ in 1:length(values[1])]

function reduce_output(keys, values, f, method, broadcasted, recursive)
    keys_out = eltype(keys)[]
    errors = Float64[]
    values_out = map(zip(keys, values)) do (key, value)
        push!(keys_out, "$method"*"_"*"$key")
        value_out, error = f(value)
        push!(errors, error)
        value_out
    end
    return keys_out, values_out, errors
end

function reduce_output(keys, values, f, method, ::Type{Val{:broadcasted}}, ::Type{Val{:recursive}})
    keys_out = "$method" * "_" .* keys
    errors = [zeros(length(keys)) for _ in 1:length(values)]
    values_out = map(enumerate(values)) do (i, values_for_folder)
        map(enumerate(values_for_folder)) do (j, values_for_key)
            value_out, error = f(values_for_key)
            errors[i][j] = error
            value_out
        end
    end
    return keys_out, values_out, errors
end

function reduce_output(keys, values, f, broadcasted, ::Type{Val{:recursive}})
    keys_out = eltype(keys)[]
    errors = Float64[]
    values_out = map(enumerate(keys)) do (k, key)
        push!(keys_out, "$method"*"_"*"$key")
        values_for_key = [value[k] for value in values]
        value_out, error = f(values_for_key)
        push!(errors, error)
        value_out
    end
    return keys_out, values_out, errors
end

"""
    write_output(output_file, keys, values, errors; folder="none")

Writes the output data to a specified file or prints it to the console, based on the file type. If `output_file` has an `.h5` extension, the data is saved in HDF5 format; otherwise, the key-value-error pairs are printed.

# Arguments
- `output_file`: A string specifying the name and path of the file to write the output. If it ends in `.h5`, the data is written in HDF5 format.
- `keys`: A vector of strings representing the keys for each value to write.
- `values`: A vector of values associated with each key.
- `errors`: A vector of error values associated with each value.
- `folder`: (Optional) A string specifying a folder identifier for output organization when printing. Defaults to `"none"`.
"""
function write_output(output_file, keys, values, errors; folder="none")
    if occursin(".h5", output_file)
        write_data_to_hdf5(output_file, keys, values)
    else
        for (key, value, error) in zip(keys, values, errors)
            print_output(key, value, folder=folder, error=error)
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
- `err
"""
function print_output(key, value; folder="none", error=0.)
    out = "The value for $key "
    if folder ≠ "none"; out *= "in $folder "; end
    out *= "is: $value"
    if error ≠ 0.; out *= " ± $error"; end
    out *= "."
    println(out)
end

function get_method(method)
    if method == "mean"
        return x->(mean(x), std(x))
    elseif method == "max"
        return x->(maximum(x), 0.)
    elseif method == "min"
        return x->(minimum(x), 0.)
    elseif method == "last"
        return x->(x[end], 0.)
    elseif method == "lastdiff"
        return x->(diff(x[end]), 0.)
    elseif method == "first"
        return x->(x[1], 0.)
    elseif method == "diff"
        return x->(diff(x), 0.)
    elseif method == "sumdiff"
        return x->(sum(vcat(diff(x)...)), 0.)
    elseif method == "rmsdiff"
        return x->(√mean(vcat(diff(x)...).^2), 0.)
    elseif method == "maxdiff"
        return x->(maximum(vcat(diff(x)...)), 0.)
    end
    return Val{Symbol("none")}
end