"""
    change_incar!(keyword::AbstractString, value::AbstractString, file::AbstractString)

Modify the value of a specified keyword in the INCAR file.

# Arguments
- `keyword::AbstractString`: The keyword in the INCAR file whose value needs to be changed.
- `value::Any`: The new value to set for the specified keyword.
- `file::AbstractString`: The path to the INCAR file.

# Example
```julia
set_keyword_in_incar!("ENCUT", 520, "INCAR")

This changes the value of the ENCUT keyword to 520 in the INCAR file located at the specified path.
"""
function set_keyword_in_incar!(keyword, value, file; out=file, block_label="", verbose=true)
    incar = read_incar(file)
    set_keyword!(keyword, value, incar, block_label=block_label, verbose=verbose)
    write_incar(incar, out)
end

function remove_keyword_from_incar!(keyword, file; out=file, verbose=true)
    incar = read_incar(file)
    remove_keyword!(keyword, incar, verbose=verbose)
    write_incar(incar, out)
end

function add_block_to_incar!(block_label, filename)
    incar = read_incar(filename)
    add_incar_block!(block_label, incar)
    write_incar(filename)
end

function remove_block_from_incar!(block_label, filename)
    incar = read_incar(filename)
    rm_incar_block!(incar, block_label)
    write_incar(incar, filename)
end