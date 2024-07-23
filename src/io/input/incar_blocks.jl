"""
    add_incar_block!(incar::OrderedDict{String, Vector{IncarLine}}, block_label::String, block_lines::Vector{IncarLine})

Add a block of lines to the INCAR file under a specified block label. If the block label 
already exists in the INCAR file, the lines will be appended to the existing block. 
If the block label does not exist, a new block will be created.

# Arguments
- `incar::OrderedDict{String, Vector{IncarLine}}`: The dictionary representing the INCAR file where the keys are block labels and the values are vectors of `IncarLine` objects.
- `block_label::String`: The label of the block to which the lines should be added.
- `block_lines::Vector{IncarLine}`: A vector of `IncarLine` objects to be added to the block.
"""
function add_incar_block!(incar::OrderedDict{String, Vector{IncarLine}}, block_label::String, block_lines::Vector{IncarLine})
    if haskey(incar, block_label)
        append!(incar[block_label], block_lines)
    else
        incar[block_label] = block_lines
    end
end

function add_incar_block!(incar, block_label::Type{Val{:Parallelization}})
    block_lines = IncarLine[]
    push!(block_lines, IncarLine("NCORE", "1", get_comment("NCORE")))
    push!(block_lines, IncarLine("KPAR", "1", get_comment("KPAR")))
    add_incar_block!(incar, string(block_label.parameters[1]), block_lines)
end

function add_incar_block!(incar, block_label::Type{Val{:Convergence}})
    block_lines = IncarLine[]
    push!(block_lines, IncarLine("ENCUT", "250", get_comment("ENCUT")))
    push!(block_lines, IncarLine("EDIFF", "1e-5", get_comment("EDIFF")))
    push!(block_lines, IncarLine("KGAMMA", "True", get_comment("KGAMMA")))
    push!(block_lines, IncarLine("KSPACING", "0.5", get_comment("KSPACING")))
    add_incar_block!(incar, string(block_label.parameters[1]), block_lines)
end

"""
    rm_incar_block!(incar::OrderedDict{String, Vector{IncarLine}}, block_label::String)

Remove a block of lines from the INCAR file under a specified block label. 
If the block label exists in the INCAR file, it will be removed. 
If the block label does not exist, a message will be printed indicating that the block is not found.

# Arguments
- `incar::OrderedDict{String, Vector{IncarLine}}`: The dictionary representing the INCAR file where the keys are block labels and the values are vectors of `IncarLine` objects.
- `block_label::String`: The label of the block to be removed.
"""
function rm_incar_block!(incar::OrderedDict{String, Vector{IncarLine}}, block_label::String)
    if haskey(incar, block_label)
        delete!(incar, block_label)
    else
        println("INCAR has no block $block_label.")
    end
end