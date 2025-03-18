"""
    Incar

A mutable struct representing the input parameters for VASP and Wannier90 calculations, stored as nested ordered dictionaries.

# Fields

- `vasp::OrderedDict{String, OrderedDict{String, IncarValue}}`: An ordered dictionary containing VASP input parameters.
The keys are category names (strings), and the values are ordered dictionaries of parameters within each category.

- `w90::OrderedDict{String, OrderedDict{String, IncarValue}}`: An ordered dictionary containing Wannier90 input parameters.
The keys are category names (strings), and the values are ordered dictionaries of parameters within each category.
"""
mutable struct Incar{S1,S2,S3,S4<:AbstractString, IV1,IV2<:IncarValue}
    vasp :: OrderedDict{S1, OrderedDict{S3, IV1}}
    w90 :: OrderedDict{S2, OrderedDict{S4, IV2}}
end

"""
    set_key!(incar::Incar, key::AbstractString, incar_value::IncarValue, block_label::AbstractString, isW90::Bool)

Set a key-value pair in the specified block of an `Incar` object, either in the VASP or WANNIER90 dictionary.

# Arguments
- `incar::Incar`: The `Incar` object to be modified.
- `key::AbstractString`: The key to be set.
- `incar_value::IncarValue`: The value to be associated with the key.
- `block_label::AbstractString`: The label of the block in which to set the key-value pair.
- `isW90::Bool`: A boolean flag indicating whether to set the key in the WANNIER90 (`true`) or VASP (`false`) dictionary.
"""
function set_key!(incar::Incar, key::AbstractString, incar_value::IncarValue, block_label::AbstractString, isW90::Bool)
    key_dict = isW90 ? incar.w90 : incar.vasp
    block_label = occursin("proj", key) ? "Projections" : block_label
    if haskey(key_dict, block_label)
        key_dict[block_label][key] = incar_value
    else
        key_dict[block_label] = OrderedDict{String, IncarValue}(key=>incar_value)
    end
end

get_empty_incar() = Incar(OrderedDict{String, OrderedDict{String, IncarValue}}(), OrderedDict{String, OrderedDict{String, IncarValue}}())

"""
    read_incar(file::String) -> Incar

Reads an INCAR file and returns an `Incar` object containing the parsed parameters for VASP and Wannier90 calculations.

# Arguments

- `file::String`: The path to the INCAR file to be read.

# Returns

- `Incar`: An `Incar` object populated with the parameters from the INCAR file.
"""
function read_incar(file::AbstractString)
    lines = open_and_read(file)

    # Begin a new line at each semicolon
    check_for_semicolon!(lines)

    incar = get_empty_incar()
    block_label = "unknown"
    isW90 = false; isprojection = false

    for line in lines
        if occursin("begin projections", line); isprojection = true; end
        if occursin("end", line) && isprojection; isprojection = false; end
        if isblock_label(line)
            block_label = get_block_label(line)
        elseif iscomment(line)
            @warn "Ignoring comment"
        elseif occursin('=', line) || (isprojection && occursin(':', line))
            key, value, comment = isprojection ? read_incar_line(line, [':', '!', '#']) : read_incar_line(line)
            comment = comment == "" ? get_comment(key) : comment
            key = isprojection ? "proj"*key : key
            if key ≠ "WANNIER90_WIN"
                set_key!(incar, key, value, comment=comment, block_label=block_label, isW90=isW90, verbose=false)
            elseif key == "WANNIER90_WIN"
                isW90 = true
            end
        elseif isW90 && occursin('\"', line)
            isW90 = false
        end
    end
    return incar
end

"""
    Base.haskey(incar::Incar, key::String) -> Bool

Checks if a specified key exists in the `Incar` object.

# Arguments
- `incar::Incar`: An `Incar` object containing `vasp` and `w90` dictionaries.
- `key::String`: The key to search for within the `vasp` and `w90` dictionaries of the `Incar` object.

# Returns
- `Bool`: Returns `true` if the key is found in either the `vasp` or `w90` dictionaries of the `Incar` object, otherwise returns `false`.
"""
function Base.haskey(incar::Incar, key::AbstractString)
    for block_dict in [incar.vasp, incar.w90], block_label in keys(block_dict)
        if haskey(block_dict[block_label], key); return true; end
    end
    false
end

"""
    hasblock(incar::Incar, block_label) -> (Bool, Bool)

Check whether a specific block is present in the given `Incar` structure.

# Arguments
- `incar::Incar`: The `Incar` object, which contains fields `vasp` and `w90` representing different configurations.
- `block_label`: A string or symbol representing the label of the block to be checked.

# Returns
- A tuple `(Bool, Bool)` where:
    - The first value is `true` if the block is found in the `vasp` fields of `Incar`.
    - The second value is `true` if the block is found in the `w90` field.
"""
function hasblock(incar::Incar, block_label)
    if haskey(incar.vasp, block_label)
        return true, false
    elseif haskey(incar.w90, block_label)
        return false, true
    else
        return false, false
    end
end

"""
    findkey(incar::Incar, key) -> Tuple{Union{Nothing, String}, Bool}

Finds the block label in which a specified key exists within the `Incar` object.

# Arguments
- `incar::Incar`: An `Incar` object containing `vasp` and `w90` dictionaries.
- `key::String`: The key to search for within the `vasp` and `w90` dictionaries of the `Incar` object.

# Returns
- `Tuple{Union{Nothing, String}, Bool}`: A tuple where the first element is either the block label containing the key or `nothing` if the key is not found. The second element is a boolean indicating whether the key was found in the `w90` dictionary (`true`) or the `vasp` dictionary (`false`).
"""
function find_key(incar::Incar, key::AbstractString)
    block_label = findfirst(dict->haskey(dict, key), incar.vasp)
    if isnothing(block_label)
        return findfirst(dict->haskey(dict, key), incar.w90), true
    else
        return block_label, false
    end
end

"""
    find_value_and_comment(incar::Incar, key::String)

Retrieves the value associated with a specified key from an `Incar` object, which may contain different formats for `w90` or `vasp`.
If the key is not found, an error is thrown.

# Arguments
- `incar::Incar`: An `Incar` object that holds the configuration data. This object can contain `w90` and `vasp` blocks.
- `key::String`: The key whose value and associated comment are to be retrieved from the `Incar` object.

# Returns
- Returns the value associated with the specified `key`. If the key exists, the function will return the value from the appropriate block (`w90` or `vasp`) depending on the format.
"""
function find_value_and_comment(incar::Incar, key::AbstractString)
    if haskey(incar, key)
        block_label, isW90 = find_key(incar, key)
        if isW90
            return incar.w90[block_label][key]
        else
            return incar.vasp[block_label][key]
        end
    end
    throw(KeyError("Value for $key not found!"))
end

find_value(incar::Incar, key) = find_value_and_comment(incar, key).value
find_comment(incar::Incar, key) = find_value_and_comment(incar, key).comment

"""
    set_key!(incar::Incar, key, value; comment=get_comment(key), block_label="", verbose=true, isW90=false)

Sets the value associated with a given key in the `Incar` object. This function handles both VASP and Wannier90 input data structures
and updates the relevant section based on the key.

# Arguments
- `incar::Incar`: The `Incar` object containing the data structures for VASP and Wannier90.
- `key::String`: The key for which the value needs to be set.
- `value`: The new value to be assigned to the key.
- `comment::String`: Optional. The comment to be associated with the key-value pair. If not provided, it defaults to a comment obtained from `get_comment(key)`. If a comment already exists, it will override this parameter.
- `block_label::String`: Optional. The label for the block within which the key-value pair is stored. Defaults to an empty string.
- `verbose::Bool`: Optional. If `true`, the function prints the changed line to the standard output. Defaults to `true`.
- `isW90::Bool`: Optional. If `true`, the function assumes the key belongs to Wannier90 input. If `false`, it infers the type based on the key.
"""
function set_key!(incar::Incar, key::AbstractString, value::AbstractString; comment=get_comment(key), block_label="", verbose=true, isW90=false)
    if isW90 == false
        isW90 = iswannier90key(key) ? true : false
    end
    
    # Add Wannier90 block if Wannier90 key is added
    if isW90 && !haskey(incar.vasp, "Wannier90") 
        incar.vasp["Wannier90"] = OrderedDict{String, IncarValue}()
    end

    if haskey(incar, key)
        old_comment = find_comment(incar, key)
        comment = old_comment == "" ? comment : old_comment
        block_label = block_label == "" ? find_key(incar, key)[1] : block_label
        remove_key!(incar, key, verbose=false)
    else
        block_label = block_label == "" ? get_block_label_for_keyword(key) : block_label
    end

    set_key!(incar, key, IncarValue(value, comment), block_label, isW90)
    
    # num_wann should be set as a VASP and a W90 keyword
    if key == "num_wann"
        set_key!(incar, "NUM_WANN", IncarValue(value, comment), "Wannier90", false)
    elseif key == "NUM_WANN"
        set_key!(incar, "num_wann", IncarValue(value, comment), get_block_label_for_keyword("num_wann"), true)
    end

    if verbose
        print("Changed line: ")
        write_line(key, find_value_and_comment(incar, key), stdout)
    end
end

function set_key!(incar::Incar, keys::AbstractVector, values::AbstractVector; block_label="", verbose=true)
    for (key, value) in zip(keys, values)
        set_key!(incar, key, value, block_label=block_label, verbose=verbose)
    end
end

function remove_key!(incar::Incar, key::AbstractString; verbose=true)
    if haskey(incar, key)
        incar_value = find_value_and_comment(incar, key)
        block_label, isW90 = find_key(incar, key)
        if isW90
            delete!(incar.w90[block_label], key)
        else
            delete!(incar.vasp[block_label], key)
        end
        if verbose
            print("Removed line: ")
            write_line(key, incar_value, stdout)
        end
    else
        @warn "key $key was not found."
    end
end

"""
    write_incar(blocks, filename)

Create an INCAR file from the tags stored in `blocks` and writes them to a file with name `filename`.
"""
function write_incar(incar::Incar, filename="INCAR")
    file = open(filename, "w")
    for (block_label, block_lines) in incar.vasp
        println(file, "!"*block_label)
        for (key, incar_value) in block_lines
            write_line(key, incar_value, file)
        end
        if block_label == "Wannier90" && length(incar.w90) > 0
            isprojection = false
            println(file, " WANNIER90_WIN = \"")
            for (w90_label, w90_lines) in incar.w90
                println(file, "  !"*w90_label)
                for (w90_key, w90_value) in w90_lines
                    if occursin("proj", w90_key) && isprojection == false
                        println(file, "   begin projections")
                        isprojection = true
                    elseif !occursin("proj", w90_key) && isprojection == true
                        println(file, "   end projections")
                        isprojection = false
                    end
                    w90_key = isprojection ? string(w90_key[5:end]) : w90_key
                    write_line(w90_key, w90_value, file, isW90=true, isprojection=isprojection)
                end
                if isprojection
                    println(file, "   end projections")
                    isprojection = false
                end
                if w90_label ≠ collect(keys(incar.w90))[end]; println(file, ""); end
            end
            
            println(file, " \"")
        end
        if block_label ≠ collect(keys(incar.vasp))[end]; println(file, ""); end
    end
    close(file)
end