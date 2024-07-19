"""
list of available tasks:

calculation
    bandgap: returns the bandgap calculated from a eigenval file
"""


function run_task(::Type{Val{:calculate}}, ::Type{Val{:bandgap}}, args)
    get_bandgap(args["p"]*args["eigenval"])    
end