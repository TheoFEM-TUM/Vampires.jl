"""
list of available tasks:

modify
    incar: changes a parameter _par_ to a given value _value_
addincar
    block_label: add certain tags to the INCAR file.
rmincar
    block_label: remove block from the INCAR file.
"""




"""
    run_parameter_test(param::AbstractString, param_range::AbstractVector; path::AbstractString="./")

Create directories for parameter testing and copy necessary files into each directory.

# Arguments
- `param::AbstractString`: The parameter to be tested.
- `param_range::AbstractVector`: A range or vector of values to test for the parameter.
- `path::AbstractString="./"`: The base path where the directories and files are located. Default is the current directory.
"""
function run_task(::Type{Val{:modify}}, ::Type{Val{:incar}}, args)
    set_keyword_in_incar!(args["par"], args["val"], args["p"]*args["incar"], out=args["p"]*args["incar"])
end

function run_task(::Type{Val{:addincar}}, block_label, args)
    incar = read_incar(args["p"]*args["incar"])
    add_incar_block!(incar, block_label)
    write_incar(incar, args["p"]*args["incar"])
end

function run_task(::Type{Val{:rmincar}}, block_label, args)
    incar = read_incar(args["p"]*args["incar"])
    rm_incar_block!(incar, string(block_label.parameters[1]))
    write_incar(incar, args["p"]*args["incar"])
end