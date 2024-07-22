"""
list of available tasks:

modify
    incar: changes a parameter _par_ to a given value _value_
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
    # TODO: this is not optimal since the output argument would need to specify the full path
    set_keyword_in_incar!(args["par"], args["val"], args["p"]*args["INCAR"], out=args["o"])
end