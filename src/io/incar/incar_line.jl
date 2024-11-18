"""
    IncarValue

A mutable struct representing a parameter value and its associated comment in an INCAR file for VASP and Wannier90 calculations.

# Fields

- `value::String`: The value of the parameter.
- `comment::String`: A comment or description associated with the parameter value.
"""
mutable struct IncarValue{S1,S2<:AbstractString}
    value :: S1
    comment :: S2
end

"""
    read_incar_line(line::String, chars=['=', '!', '#']) -> Vector{String}

Parses a line from an INCAR file into its key, value, and comment components.

# Arguments

- `line::String`: The line from the INCAR file to be parsed.
- `chars::Vector{Char}=['=', '!', '#']`: A vector of characters to split the line by.
The default characters are '=', '!', and '#'.

# Returns

- `Vector{String}`: A vector containing the key, value, and comment as strings. If no comment is present, an empty string is returned in the third position.
"""
function read_incar_line(line, chars=['=', '!', '#'])
    line_sp = strip.(split_line(line, char=chars), ' ')
    if length(line_sp) == 2
        push!(line_sp, "")
    elseif length(line_sp) < 2
        throw(ArgumentError("Line must contain both a key and a value: $line"))
    end
    return string.(line_sp)
end

"""
    check_for_semicolon!(lines)

Processes the `lines` array to handle lines containing semicolons (`;`). The function performs the following actions:

1. Detects blocks of lines that are within "projections" sections, which are enclosed by "begin projections" and "end" keywords.
2. For lines not within projections, if a line contains a semicolon, it splits the line at the semicolon and processes each segment:
    - The portion before the semicolon remains in the original line.
    - Portions after the semicolon are inserted as new lines immediately after the current line.

# Arguments
- `lines::Vector{String}`: A mutable vector of strings representing lines of text. The function modifies this vector in place.
"""
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
get_block_label(line) = strip(replace(line, ['!', '#']=>' '), ' ')

iswannier90key(key) = uppercase(key) ≠ key

"""
    write_line(key, incar_value, file; isW90=false, isprojection=false)

Writes a formatted line to the specified file. The format and indentation of the line are determined by the optional keyword arguments `isW90` and `isprojection`.

# Arguments
- `key::String`: The key or label to be written at the beginning of the line.
- `incar_value::Dict{Symbol, Any}`: A dictionary containing `value` and optionally `comment` fields. The `value` field is used as the value to be written after the key. If a `comment` is present, it will be appended to the end of the line.
- `file::IO`: The file or I/O stream to which the line will be written.

# Keyword Arguments
- `isW90::Bool`: If true, modifies the indentation of the line. If false, uses default indentation.
- `isprojection::Bool`: If true, changes the separator between the key and the value to a colon (":"). If false, uses " = " as the separator.

"""
function write_line(key, incar_value, file; isW90=false, isprojection=false)
    Nin = isW90 ? isprojection ? 6 : 3 : 1
    sep = isprojection ? ":" : " = "
    line_string = " "^Nin * key * sep * incar_value.value
    L = length(line_string)
    N_spaces = 35 - L
    if length(incar_value.comment) > 1; line_string *= " "^N_spaces * "!" * incar_value.comment; end
    println(file, line_string)
end

iscomment(line) = length(strip(line, ' ')) ≥ 1 ? strip(line, ' ')[1] == '!' || strip(line, ' ')[1] == '#' : false