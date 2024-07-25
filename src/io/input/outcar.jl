"""
    read_value_from_outcar(param, file; mode="first", type=Float64, N=1)

Read values associated with a parameter from a file.

# Arguments
- `param::AbstractString`: The parameter to search for in the file.
- `file::AbstractString`: The path to the file to read from.
- `mode::AbstractString`: Determines whether to extract the "first" or "last" occurrence of the value in the line. Defaults to "first".
- `type::Type`: The data type to which the values should be converted. Defaults to `Float64`.


# Returns
- `param_values::Vector{type}`: A vector of values of the specified type associated with the parameter found in the file.

# Description
This function reads a file line-by-line and searches for lines containing the specified parameter `param`. 
It extracts the values associated with the parameter from each line, converts them to the specified `type`, and collects them in a vector.
"""
function read_value_from_outcar(param, file; type=Float64, line_mode="first")::Vector
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
    else
        return param_values
    end
end