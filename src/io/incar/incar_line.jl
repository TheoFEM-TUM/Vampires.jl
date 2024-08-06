"""
    mutable struct IncarValue

A mutable struct representing a line in an INCAR file used by VASP.

# Fields
- `value::String`: The value associated with the key.
- `comment::String`: An optional comment describing the line or providing additional information.

# Description
The `IncarLine` struct is used to model a single line in a VASP INCAR file. This file is used to specify parameters and settings for a VASP calculation. 
Each line typically consists of a key and its associated value, and optionally a comment that explains the purpose or details of the line.
"""
mutable struct IncarValue
    value :: String
    comment :: String
end

function read_incar_line(line, chars=['=', '!', '#'])
    split_line = strip.(split(line, chars), ' ')
    if length(split_line) == 2
        push!(split_line, "")
    end
    return string.(split_line)
end

function check_for_semicolon!(lines)
    isprojection = false
    for (l, line) in enumerate(lines)
        if occursin("begin projections", line); isprojection = true; end
        if occursin("end", line) && isprojection; isprojection = false; end
        if occursin(';', line) && !isprojection
            sublines = split(line, ';')
            replace!(lines, line=>sublines[1])
            if length(sublines) > 1
                for subline in reverse(sublines[2:end])
                    insert!(lines, l+1, subline)
                end
            end
        end
    end
end


isblock_label(line) = iscomment(line) && occursin('=', line) == false
get_block_label(line) = strip(line, ' ')[2:end]

"""
    write_line!(line, file)

Write the  IncarLine `line` to `file`.
"""
function write_line(key, incar_value, file; isW90=false, isprojection=false)
    Nin = isW90 ? isprojection ? 4 : 3 : 1
    sep = isprojection ? ":" : " = "
    line_string = " "^Nin * key * sep * incar_value.value
    L = length(line_string)
    N_spaces = 35 - L - (Nin-1)
    if length(incar_value.comment) > 1; line_string *= " "^N_spaces * "!" * incar_value.comment; end
    println(file, line_string)
end

iscomment(line) = length(strip(line, ' ')) ≥ 1 ? strip(line, ' ')[1] == '!' || strip(line, ' ')[1] == '#' : false