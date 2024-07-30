"""
list of available tasks:

outcar
    read: read a certain value from the outcar file
"""


"""
reads last value in OUTCAR of parameter for each directory
"""
function run_task(::Type{Val{:outcar}}, ::Type{Val{:read}}, args)
    values = read_value_from_outcar(args["par"], args["p"]*args["outcar"])
    return values
end