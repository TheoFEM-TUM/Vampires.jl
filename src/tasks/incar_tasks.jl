"""
list of available tasks:

incar
    set/add: changes or adds a parameter _par_ to a given value _value_ or adds a block to the incar
    rm: remove a certain tag or block from the INCAR file.
    read: read the value of a certain INCAR tag and print it
    create: create an INCAR file with certain tags or blocks in it
    whatis: return the default comment for an INCAR tag. 
whatis
    return the default comment for an INCAR tag.
"""


"""
    run_parameter_test(param::AbstractString, param_range::AbstractVector; path::AbstractString="./")

Create directories for parameter testing and copy necessary files into each directory.

# Arguments
- `param::AbstractString`: The parameter to be tested.
- `param_range::AbstractVector`: A range or vector of values to test for the parameter.
- `path::AbstractString="./"`: The base path where the directories and files are located. Default is the current directory.
"""
function run_task(::Type{Val{:incar}}, ::Type{Val{:set}}, args)
    if length(args["par"]) > 0 
        set_key_in_incar(split_line(args["par"], char=','), split_line(args["val"], char=','), args["p"]*args["incar"], out=args["p"]*args["incar"], block_label=args["block"])
    elseif length(args["block"]) > 0
        add_block_to_incar!(split_line(args["block"], char=','), args["p"]*args["incar"])
    end
end

run_task(::Type{Val{:setincar}}, subtask, args) = run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)
run_task(::Type{Val{:incar}}, ::Type{Val{:add}}, args) = run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)
run_task(::Type{Val{:addincar}}, subtask, args) = run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)

function run_task(::Type{Val{:rm}}, ::Type{Val{:incar}}, args)
    if length(args["par"]) > 0 
        remove_key_from_incar(args["par"], args["p"]*args["incar"], out=args["p"]*args["incar"])
    elseif length(args["block"]) > 0
        remove_block_from_incar!(args["block"], args["p"]*args["incar"])
    end
end

run_task(::Type{Val{:rmincar}}, subtask, args) = run_task(Val{Symbol("rm")}, Val{Symbol("incar")}, args)

function run_task(::Type{Val{:incar}}, ::Type{Val{:whatis}}, args)
    param = args["par"]
    println("The $param keyword ", get_comment(param), " (see https://www.vasp.at/wiki/index.php/$param for more info).")
end

run_task(::Type{Val{:whatis}}, subtask, args) = run_task(Val{Symbol("incar")}, Val{Symbol("whatis")}, args)

function run_task(::Type{Val{:incar}}, ::Type{Val{:read}}, args)
    incar = read_incar(args["p"]*args["incar"])
    for key in split_line(args["par"], char=',')
        value = find_value(incar, key).value
        println("The value of $key is: $value")
    end
end

function run_task(::Type{Val{:incar}}, ::Type{Val{:create}}, args)
    incar = OrderedDict{String, Vector{IncarLine}}()
    if length(args["par"]) > 0
        for key in split_line(args["par"], char=',')
            set_key!(incar, key, get_default_for_keyword(key), block_label=args["block"])
        end
    elseif length(args["block"]) > 0
        add_incar_block!(split_line(args["block"], char=','), incar)
    end
    write_incar(incar, args["p"]*args["incar"])
end