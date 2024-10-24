"""
list of available tasks:

calculation
    bandgap: returns the bandgap calculated from a eigenval file
"""


# TODO: unify this with read methods, i.e., vamp [file] read --par bandgap
function run_task(::Type{Val{:calculate}}, ::Type{Val{:bandgap}}, args)
    ΔE = get_bandgap(args["p"]*args["eigenval"])
    @show ΔE
    return ΔE
end