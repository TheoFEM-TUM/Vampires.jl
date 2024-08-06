mutable struct Incar
    vasp :: OrderedDict{String, OrderedDict{String, IncarValue}}
    w90 :: OrderedDict{String, OrderedDict{String, IncarValue}}
end

get_empty_incar() = Incar(OrderedDict{String, OrderedDict{String, IncarValue}}(), OrderedDict{String, OrderedDict{String, IncarValue}}())

"""
    read_incar(file)

Read the INCAR file at `file`.
"""
function read_incar(file::String)
    lines = open_and_read(file)
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
        elseif occursin('=', line)
            key, value, comment = isprojection ? read_incar_line(line, [':', '!', '#']) : read_incar_line(line)
            comment = comment == "" ? get_comment(key) : comment
            key = isprojection ? "proj"*key : key
            if key ≠ "WANNIER90_WIN"
                set_key!(incar, key, value, comment=comment, block_label=block_label, isW90=isW90, verbose=false)
            elseif isW90 && occursin('\"', line)
                isW90 = false
            else
                isW90 = true
            end
        end
    end
    return incar
end


function Base.haskey(incar::Incar, key::String)
    for block_dict in [incar.vasp, incar.w90], block_label in keys(block_dict)
        if haskey(block_dict[block_label], key); return true; end
    end
    false
end


function findkey(incar::Incar, key)
    block_label = findfirst(dict->haskey(dict, key), incar.vasp)
    if isnothing(block_label)
        return findfirst(dict->haskey(dict, key), incar.w90), true
    else
        return block_label, false
    end
end

function findvalue(incar::Incar, key)
    if haskey(incar, key)
        block_label, isW90 = findkey(incar, key)
        if isW90
            return incar.w90[block_label][key]
        else
            return incar.vasp[block_label][key]
        end
    end
    throw(KeyError("Value for $key not found!"))
end

"""
    set_key!(key, value, blocks; comment)

Sets the `key` to `value` in `blocks` with `comment`.
"""
function set_key!(incar::Incar, key, value; comment=get_comment(key), block_label="", verbose=true, isW90=false)
    if haskey(incar, key)
        block_label, isW90 = findkey(incar, key)
        old_comment = findvalue(incar, key).comment
        comment = old_comment == "" ? comment : old_comment
        if isW90
            incar.w90[block_label] = IncarValue(value, comment)
        else
            incar.vasp[block_label] = IncarValue(value, comment)
        end
    else
        if !isW90
            if haskey(incar.vasp, block_label)
                incar.vasp[block_label][key] = IncarValue(value, comment)
            else
                incar.vasp[block_label] = OrderedDict{String, IncarValue}(key=>IncarValue(value, comment))
            end
        else
            if haskey(incar.w90, block_label)
                incar.w90["unknown"][key] = IncarValue(value, comment)
            else
                incar.w90["unknown"] = OrderedDict{String, IncarValue}(key=>IncarValue(value, comment))
            end
        end
    end
    if verbose
        print("Changed line: ")
        write_line(key, findvalue(incar, key), stdout)
    end
end

function set_key!(incar::Incar, keys::AbstractVector, values::AbstractVector; block_label="", verbose=true)
    for (key, value) in zip(keys, values)
        set_key!(incar, key, value, block_label=block_label, verbose=verbose)
    end
end

function remove_key!(incar::Incar, key::AbstractString; verbose=true)
    if haskey(incar, key)
        incar_value = findvalue(incar, key)
        block_label, isW90 = findkey(incar, key)
        if isW90
            delete!(incar.w90[block_label], key)
        else
            delete!(incar.vasp[block_label], key)
        end
        if verbose && length(key_line) > 0
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
        if block_label == "Wannier90"
            println(file, " WANNIER90_WIN = \"")
            for (w90_label, w90_lines) in incar.w90
                println(file, "  !"*w90_label)
                for (w90_key, w90_value) in w90_lines
                    isprojection = occursin("proj", w90_key) ? true : else
                    write_line(key, incar_value, file, isW90=true)
                end
            end
            println(file, " \"")
        end
        if block_label ≠ collect(keys(incar.vasp))[end]; println(file, ""); end
    end
    close(file)
end