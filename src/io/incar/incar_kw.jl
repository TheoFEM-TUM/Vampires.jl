"""
    set_key_in_incar(key, value, file; out=file, block_label="", verbose=true)

Updates a specified key with a new value in an INCAR file and writes the modified content to a specified output file.

# Arguments
- `key::String`: The key in the INCAR file that you want to update.
- `value::Any`: The new value to assign to the specified key.
- `file::String`: The input filename from which the INCAR content will be read.

# Keyword Arguments
- `out::String`: The output filename where the modified INCAR content will be written. Defaults to the same file as `file`.
- `block_label::String`: A label indicating the block in which the key is to be set. Defaults to an empty string, meaning no specific block label is used.
- `verbose::Bool`: If true, enables verbose mode, providing detailed output during the update process. Defaults to true.
"""
function set_key_in_incar(key, value, file; out=file, block_label="", verbose=true)
    incar = read_incar(file)
    set_key!(incar, key, value, block_label=block_label, verbose=verbose)
    write_incar(incar, out)
end

"""
    remove_key_from_incar(key, file; out=file, verbose=true)

Removes a specified key from an INCAR file and writes the modified content to a specified output file.

# Arguments
- `key::String`: The key to be removed from the INCAR file.
- `file::String`: The path to the input INCAR file from which the key will be removed.

# Keyword Arguments
- `out::String`: The path to the output file where the modified INCAR content will be written. Defaults to the same file as `file`.
- `verbose::Bool`: If true, enables verbose mode, providing detailed output about the removal process. Defaults to true.
"""
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