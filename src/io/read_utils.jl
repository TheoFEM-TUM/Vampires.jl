"""
    open_and_read(file::AbstractString) -> Vector{String}

Open a file, read all lines, and return them as a vector of strings.

# Arguments
- `file::AbstractString`: The path to the file to be read.

# Returns
- `lines::Vector{String}`: A vector where each element is a line from the file.
"""
function open_and_read(file)
    f = open(file)
    lines = readlines(f)
    close(f)
    return lines
end

"""
    split_lines(lines::Vector{String}) -> Vector{Vector{String}}

Split each line of the input vector of strings into its constituent non-empty elements.

# Arguments
- `lines::Vector{String}`: A vector of strings, where each string represents a line to be split.

# Returns
- `split_lines::Vector{Vector{String}}`: A vector of vectors of strings, where each inner vector 
contains the non-empty elements of the corresponding line from the input.
"""
function split_lines(lines; char=" ")
    split_lines = Vector{Vector{String}}(undef, length(lines))
    Threads.@threads for l in eachindex(lines)
        split_lines[l] = split_line(lines[l]; char=char)
    end
    return split_lines
end

"""
    split_line(line::String) -> Vector{String}

Splits a line of text into individual words, removing any extra spaces.

# Arguments
- `line::String`: A string representing the line of text to be split.

# Returns
- `Vector{String}`: An array of words from the input line, excluding any empty elements.
"""
split_line(line; char=" ") = filter(!isempty, split(line, char))

"""
    parse_lines_as_array(line; i1, i2, type)

Parse `lines` as a 2d array of `type` starting from index `i1` ending at `i2` in
each line.
"""
function parse_lines_as_array(lines; i1=1, i2=3, type=Float64)
    Nj = length(lines); Ni = length(i1:i2)
    array = Array{type, 2}(undef, Nj, Ni)
    for (j, line) in enumerate(lines)
        array[j, :] = parse.(type, line[i1:i2])
    end
    return array
end

"""
    next_line_with(keywords, lines)

Find the next line in lines that contains a set of keywords.
"""
function next_line_with(keywords::AbstractArray, lines)
    index = false; keyline = false
    for (i, line) in enumerate(lines)
        if all(keyword->keyword in line, keywords)
            index = i
            keyline = line
            return index, keyline
        end
    end
end

next_line_with(s::String, lines) = next_line_with([s], lines)

"""
    write_to_file(M, filename)

Write the Array `M` and shape to a new file with name `filename`.
"""
function write_to_file(M, filename)
    file = open(filename*".dat", "w")
    print(file, "   "); for k in 1:length(size(M)); print(file, size(M, k), "  "); end; print(file, "\n")
    for e in collect(Iterators.flatten(M))
        println(file, e)
    end
    close(file)
end

"""
    read_from_file(filename, type)

Read an Array `M` with elements of `type` from the file with name `filename`.
"""
function read_from_file(filename; type=Float64)
    lines = open_and_read(filename)
    Ns = Tuple(parse.(Int64, filter!(el->el≠"", split(lines[1], " "))))
    M = parse.(type, lines[2:end])
    return reshape(M, Ns)
end

"""
    to_scalar_if_single(x)::Vector

Converts an AbstractVector to a single value if length is 1.
"""
function to_scalar_if_single(x::AbstractVector)
    length(x) == 1 ? x[1] : x
end

"""
    write_data_to_hdf5(output_filename::String, data_keys::Vector{String}, data_values::Vector)

Write multiple datasets to an HDF5 file, associating each dataset with a corresponding key.

# Arguments
- `output_filename::String`: The name of the HDF5 file where the data will be saved. If the file already exists, the existing datasets may be modified or overwritten.
- `data_keys::Vector{String}`: A vector containing the names (keys) to be used for each dataset in the HDF5 file.
- `data_values::Vector`: A vector containing the datasets to be written to the HDF5 file. Each entry in `data_values` corresponds to the respective entry in `data_keys`.
"""
function write_data_to_hdf5(output_filename, data_keys, data_values)
    h5open(output_filename, "cw") do file
        for (data_key, data_value) in zip(data_keys, data_values)
            write_key_to_hdf5(file, data_key, data_value)
        end
    end
end

"""
    write_key_to_hdf5(file::HDF5.File, data_key::String, data_value::Number)

Append or write a dataset in an HDF5 file with a new number.

# Arguments
- `file::HDF5.File`: An open HDF5 file where the data will be written.
- `data_key::String`: The name (key) for the dataset in the HDF5 file.
- `data_value::Number`: A number containing the new value to be written under the `data_key`.
"""
function write_key_to_hdf5(file, data_key, data_value::Number)
    if haskey(file, data_key)
        current_size = size(file[data_key])
        if length(current_size) == 0
            new_data_value = Array{eltype(data_value)}(undef, 2)
            new_data_value[1] = read(file[data_key])
            new_data_value[2] = data_value
            delete_object(file, data_key)
            file[data_key] = new_data_value
        else
            new_data_value = Array{eltype(data_value)}(undef, current_size[1]+1)
            new_data_value[1:end-1] .= read(file[data_key])
            new_data_value[end] = data_value
            delete_object(file, data_key)
            file[data_key] = new_data_value
        end
    else
        file[data_key] = data_value
    end
end

"""
    write_key_to_hdf5(file::HDF5.File, data_key::String, data_value::AbstractVector)

Append or write a dataset in an HDF5 file with a new vector or matrices.

# Arguments
- `file::HDF5.File`: An open HDF5 file where the data will be written.
- `data_key::String`: The name (key) for the dataset in the HDF5 file.
- `data_value::AbstractVector`: A vector containing the new data to be written under the `data_key`.
"""
function write_key_to_hdf5(file, data_key, data_value::AbstractVector)
    if haskey(file, data_key)
        current_size = size(file[data_key])
        if length(current_size) == 1
            new_data_value = Array{eltype(data_value)}(undef, current_size[1], 2)
            new_data_value[:, 1] = read(file[data_key])
            new_data_value[:, 2] .= data_value
            delete_object(file, data_key)
            file[data_key] = new_data_value
        else
            new_data_value = Array{eltype(data_value)}(undef, current_size[1], current_size[2]+1)
            new_data_value[:, 1:end-1] = read(file[data_key])
            new_data_value[:, end] .= data_value
            delete_object(file, data_key)
            file[data_key] = new_data_value
        end
    else
        file[data_key] = data_value
    end
end

"""
    write_key_to_hdf5(file::HDF5.File, data_key::String, data_value::AbstractMatrix)

Append or write a dataset in an HDF5 file with a new 2D matrix or stack of matrices.

# Arguments
- `file::HDF5.File`: An open HDF5 file where the data will be written.
- `data_key::String`: The name (key) for the dataset in the HDF5 file.
- `data_value::AbstractMatrix`: A 2D matrix containing the new data to be written under the `data_key`.
"""
function write_key_to_hdf5(file, data_key, data_value::AbstractMatrix)
    if haskey(file, data_key)
        current_size = size(file[data_key])
        if length(current_size) == 2
            new_data_value = Array{eltype(data_value)}(undef, current_size[1], current_size[2], 2)
            new_data_value[:, :, 1] = read(file[data_key])
            new_data_value[:, :, 2] .= data_value
            delete_object(file, data_key)
            file[data_key] = new_data_value
        else
            new_data_value = Array{eltype(data_value)}(undef, current_size[1], current_size[2], current_size[3]+1)
            new_data_value[:, :, 1:end-1] = read(file[data_key])
            new_data_value[:, :, end] .= data_value
            delete_object(file, data_key)
            file[data_key] = new_data_value
        end
    else
        file[data_key] = data_value
    end
end

"""
    write_key_to_hdf5(file::HDF5.File, data_key::String, data_value::AbstractArray{T, 3}) where {T}

Append or overwrite a 3D array dataset in an HDF5 file, allowing for the creation of a 4D array if necessary.

# Arguments
- `file::HDF5.File`: An open HDF5 file where the data will be written.
- `data_key::String`: The name (key) for the dataset in the HDF5 file.
- `data_value::AbstractArray{T, 3}`: A 3D array of type `T` to be written to the HDF5 file under `data_key`.
"""
function write_key_to_hdf5(file, data_key, data_value::AbstractArray{T, 3}) where {T}
    if haskey(file, data_key)
        current_size = size(file[data_key])
        if length(current_size) == 3
            new_data_value = Array{eltype(data_value)}(undef, current_size[1], current_size[2], current_size[3], 2)
            new_data_value[:, :, :, 1] = read(file[data_key])
            new_data_value[:, :, :, 2] .= data_value
            delete_object(file, data_key)
            file[data_key] = new_data_value
        else
            new_data_value = Array{eltype(data_value)}(undef, current_size[1], current_size[2], current_size[3], current_size[4]+1)
            new_data_value[:, :, :, 1:end-1] = read(file[data_key])
            copyto!(new_data_value[:, :, :, 1:end-1], file[data_key])
            new_data_value[:, :, :, end] .= data_value
            delete_object(file, data_key)
            file[data_key] = new_data_value
        end
    else
        file[data_key] = data_value
    end
end