"""
    add_incar_block!(incar::Incar, block_label::AbstractString; verbose::Bool=true)

Add a block of default INCAR settings to an existing INCAR object.

# Arguments
- `incar::Incar`: The INCAR object to which the block of settings will be added.
- `block_label::AbstractString`: A label identifying the block of default settings to be added.
- `verbose::Bool`: A boolean flag indicating whether to print detailed information during the operation. Default is `true`.
"""
function add_incar_block!(incar::Incar, block_label::AbstractString; verbose=true)
    keys = get_keywords_for_block(block_label)
    for key in keys
        try find_value(incar, key)
            nothing
        catch e
            value = get_default_for_keyword(key)
            set_key!(incar, key, value, block_label=block_label, verbose=verbose)
        end
    end
end

"""
    add_incar_block!(incar::Incar, block_labels::Vector{<:AbstractString}; verbose::Bool=true)

Add multiple blocks of default INCAR settings to an existing INCAR object.

# Arguments
- `incar::Incar`: The INCAR object to which the blocks of settings will be added.
- `block_labels::Vector{<:AbstractString}`: A vector of labels identifying the blocks of default settings to be added.
- `verbose::Bool`: A boolean flag indicating whether to print detailed information during the operation. Default is `true`.
"""
function add_incar_block!(incar::Incar, block_labels::Vector; verbose=true) 
    for block_label in block_labels
        add_incar_block!(incar, block_label, verbose=verbose)
    end
end

"""
    rm_incar_block!(incar::Incar, block_label::String)

Remove a block of settings from an INCAR object.

# Arguments
- `incar::Incar`: The INCAR object from which the block of settings will be removed.
- `block_label::String`: The label identifying the block of settings to be removed.
"""
function rm_incar_block!(incar::Incar, block_label::String)
    if haskey(incar, block_label)
        block_label, isW90 = find_key(incar, key)
        if isW90
            delete!(incar.w90, block_label)
        else
            delete!(incar.vasp, block_label)
        end
    else
        println("INCAR has no block $block_label.")
    end
end