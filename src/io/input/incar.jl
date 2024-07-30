"""
    mutable struct IncarLine

A mutable struct representing a line in an INCAR file used by VASP.

# Fields
- `keyword::String`: The keyword or parameter name in the INCAR file.
- `value::String`: The value associated with the keyword.
- `comment::String`: An optional comment describing the line or providing additional information.

# Description
The `IncarLine` struct is used to model a single line in a VASP INCAR file. This file is used to specify parameters and settings for a VASP calculation. 
Each line typically consists of a keyword and its associated value, and optionally a comment that explains the purpose or details of the line.
"""
mutable struct IncarLine
    keyword :: String
    value :: String
    comment :: String
end

"""
    write_line!(line, file)

Write the  IncarLine `line` to `file`.
"""
function write_line(line::IncarLine, file)
    line_string = " " * line.keyword * " = " * line.value
    L = length(line_string)
    N_spaces = 25 - L
    if length(line.comment) > 1; line_string *= " "^N_spaces * "!" * line.comment; end
    println(file, line_string)
end

"""
    hasline(lines, keyword)

Checks if there is a line with `keyword` in lines.
"""
function hasline(lines::Vector{IncarLine}, keyword::String)
    for line in lines
        if line.keyword == keyword
            return true
        end
    end
    false
end

"""
    get_block_inds(lines)

Going through the lines in the INCAR file, identify blocks by checking if the first element of a line is a space.
"""
function get_block_inds(lines::Vector{String})
    block_inds = []; block_labels = String[]
    for (l, line) in enumerate(lines)
        if line ≠ ""
            if line[1] ≠ ' '
                push!(block_inds, l)
                push!(block_labels, line[2:end])
            end
        end
    end
    block_ranges = UnitRange{Int64}[]
    for i in axes(block_inds, 1)
        first_index = block_inds[i]+1
        last_index = i == length(block_inds) ? length(lines) : block_inds[i+1]-2
        push!(block_ranges, first_index:last_index)
    end
    return block_ranges, block_labels
end

"""
    get_comment(line)

Identify if the line contains a comment and return it as a string.
"""
function get_comment(line::Vector{String})
    comment = ""
    comment_ind = 0
    for (i, element) in enumerate(line)
        if occursin('!', element)
            comment_ind = i
        end
    end
    if comment_ind ≠ 0
        comment *= line[comment_ind][2:end]
        for element in line[comment_ind+1:end]
            comment *= " "*element
        end
    end
    return comment
end

"""
    read_incar(file)

Read the INCAR file at `file`.
"""
function read_incar(file::String)
    lines = open_and_read(file)
    block_ranges, block_labels = get_block_inds(lines)
    blocks = OrderedDict{String, Vector{IncarLine}}()
    for i in axes(block_ranges, 1)
        block_lines = split_lines(lines[block_ranges[i]])
        incar_lines = IncarLine[]
        for block_line in block_lines 
            if length(block_line) > 1
                comment = get_comment(block_line)
                push!(incar_lines, IncarLine(block_line[1], block_line[3], comment))
            end
        end
        blocks[block_labels[i]] = incar_lines
    end
    check_for_empty_blocks!(blocks)
    return blocks
end

"""
    write_incar(blocks, filename)

Create an INCAR file from the tags stored in `blocks` and writes them to a file with name `filename`.
"""
function write_incar(blocks::OrderedDict, filename="INCAR")
    file = open(filename, "w")
    L = length(blocks); k = 0
    for (block_label, block_lines) in blocks
        k += 1
        println(file, "!"*block_label)
        for line in block_lines
            write_line(line, file)
        end
        if k ≠ length(blocks); println(file, ""); end
    end
    close(file)
end

"""
    check_for_empty_blocks!(blocks)
"""
function check_for_empty_blocks!(blocks)
    for (block_label, block_lines) in blocks
        if length(block_lines) == 0
            delete!(blocks, block_label)
        end
    end
end

"""
    get_value_for_keyword(keyword, blocks, block_label)
"""
function get_value_for_keyword(keyword, blocks; block_label="")
    if haskey(blocks, block_label)
        block_lines = blocks[block_label]
        for line in block_lines
            if line.keyword == keyword
                return line.value
            end
        end
    else
        for (block_label, block_lines) in blocks
            for line in block_lines
                if line.keyword == keyword
                    return line.value
                end
            end
        end
    end
    throw(KeyError("Value for $keyword not found!"))
end

"""
    set_keyword!(keyword, value, blocks; comment)

Sets the `keyword` to `value` in `blocks` with `comment`.
"""
function set_keyword!(keyword::String, value::String, blocks; comment=get_comment(keyword), block_label="", verbose=true)
    value_set = false
    if haskey(blocks, block_label)
        block_lines = blocks[block_label]
        for line in block_lines
            if line.keyword == keyword
                line.value = value
                if length(comment) > 1; line.comment = comment; end
                value_set = true
            end
        end
        if value_set == false
            push!(block_lines, IncarLine(keyword, value, comment))
        end
    elseif !haskey(blocks, block_label) && block_label ≠ ""
        remove_keyword!(keyword, blocks, verbose=false)
        blocks[block_label] = [IncarLine(keyword, value, comment)]
    else
        for (block_label, block_lines) in blocks
            for line in block_lines
                if line.keyword == keyword
                    line.value = value
                    if length(comment) > 1; line.comment = comment; end
                    value_set = true
                end
            end
        end
        if value_set == false
            block_label = get_block_label_for_keyword(keyword)
            if haskey(blocks, block_label)
                push!(blocks[block_label], IncarLine(keyword, value, comment))
            else
                blocks[block_label] = [IncarLine(keyword, value, comment)]
            end
        end
    end
    if verbose
        print("Changed line: ")
        write_line(IncarLine(keyword, value, get_comment(keyword)), stdout)
    end
    check_for_empty_blocks!(blocks)
end

function set_keyword!(keywords::AbstractVector, values::AbstractVector, blocks::OrderedDict{String, Vector{IncarLine}}; block_label="", verbose=true)
    for (keyword, value) in zip(keywords, values)
        set_keyword!(keyword, value, blocks, block_label=block_label, verbose=verbose)
    end
end

function remove_keyword!(keyword::AbstractString, blocks::OrderedDict{String, Vector{IncarLine}}; verbose=true)
    for (block_label, block_lines) in blocks
        keyword_line = [line for line in block_lines if line.keyword == keyword]
        filter!(line -> line.keyword ≠ keyword, block_lines)
        if verbose && length(keyword_line) > 0
            print("Removed line: ")
            write_line.(keyword_line, stdout)
        end
    end
end