"""
    add_incar_block!(block_label::AbstractString, incar; verbose=true)

Add a block of keywords to an INCAR dictionary.

This function adds a block of keywords and their default values to the provided `incar` dictionary. The block of keywords is identified by the `block_label`. 
Each keyword is fetched using `get_keywords_for_block(block_label)` and their default values are obtained using `get_default_for_keyword(keyword)`. 
The function then sets each keyword in the `incar` dictionary using `set_keyword!`.

# Arguments
- `block_label::AbstractString`: The label identifying the block of keywords to add.
- `incar`: The INCAR dictionary where the keywords and their values will be added.
- `verbose::Bool`: If true, print detailed information during the addition process. Defaults to `true`.
"""
function add_incar_block!(block_label::AbstractString, incar; verbose=true)
    keywords = get_keywords_for_block(block_label)
    for keyword in keywords
        value = get_default_for_keyword(keyword)
        set_keyword!(keyword, value, incar, block_label=block_label, verbose=verbose)
    end
end

function add_incar_block!(block_labels::Vector, incar; verbose=true) 
    for block_label in block_labels
        add_incar_block!(block_label, incar, verbose=verbose)
    end
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