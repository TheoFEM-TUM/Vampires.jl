"""
    read_value_from_file(param, file; mode="first", type=Float64, N=1)

Read values associated with a parameter from a file.

# Arguments
- `param::AbstractString`: The parameter to search for in the file.
- `file::AbstractString`: The path to the file to read from.
- `mode::AbstractString`: Determines whether to extract the "first" or "last" occurrence of the value in the line. Defaults to "first".
- `type::Type`: The data type to which the values should be converted. Defaults to `Float64`.
- `N::Int`: The maximum number of values to return. Defaults to 1. Set to 0 to return all matches.

# Returns
- `param_values::Vector{type}`: A vector of values of the specified type associated with the parameter found in the file.

# Description
This function reads a file line-by-line and searches for lines containing the specified parameter `param`. 
It extracts the values associated with the parameter from each line, converts them to the specified `type`, and collects them in a vector.
The `mode` argument specifies whether to extract the "first" or "last" value of the specified type in the line. 
If `mode` is "first", the function extracts the first occurrence of a value of the specified type; if `mode` is "last", it extracts the last occurrence.
The function returns a maximum of `N` values. If `N` is set to 0, all matching values are returned.
"""
function read_value_from_file(param, file; mode="last", type=Float64, N=1, line_mode="first")
    lines = open_and_read(file)
    param_values = type[]
    for line in lines
        if occursin(param, line)
            
            # Replace some symbols with space
            line_ = line
            for special_char in [':', '=']
                line_ = replace(line_, special_char => ' ')
            end

            line_elements_of_type = filter(x->x≠nothing, tryparse.(type, split_line(line_)))

            if line_mode == "first"
                push!(param_values, line_elements_of_type[1])
            elseif line_mode == "last"
                push!(param_values, line_elements_of_type[end])
            end
        end
    end
    if length(param_values) == 0
        throw("No value for parameter $param found.")
    elseif length(param_values) == 1 || N == 1
        if mode == "first"
            return param_values[1]
        elseif mode == "last"
            return param_values[end]
        end
    else
        return param_values
    end
end