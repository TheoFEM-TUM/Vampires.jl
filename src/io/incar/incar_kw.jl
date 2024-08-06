"""
    change_incar!(key::AbstractString, value::AbstractString, file::AbstractString)

Modify the value of a specified key in the INCAR file.

# Arguments
- `key::AbstractString`: The key in the INCAR file whose value needs to be changed.
- `value::Any`: The new value to set for the specified key.
- `file::AbstractString`: The path to the INCAR file.

# Example
```julia
set_key_in_incar!("ENCUT", 520, "INCAR")

This changes the value of the ENCUT key to 520 in the INCAR file located at the specified path.
"""
function set_key_in_incar(key, value, file; out=file, block_label="", verbose=true)
    incar = read_incar(file)
    set_key!(incar, key, value, block_label=block_label, verbose=verbose)
    write_incar(incar, out)
end

function remove_key_from_incar(key, file; out=file, verbose=true)
    incar = read_incar(file)
    remove_key!(incar, key, verbose=verbose)
    write_incar(incar, out)
end

function add_block_to_incar(block_label, filename)
    incar = read_incar(filename)
    add_incar_block!(incar, block_label)
    write_incar(incar, filename)
end

function remove_block_from_incar(block_label, filename)
    incar = read_incar(filename)
    rm_incar_block!(incar, block_label)
    write_incar(incar, filename)
end