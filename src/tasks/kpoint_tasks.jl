"""
list of available tasks:

kpoints
    make: generate a kpoint file for a certain grid size or kspacing, respectively.
"""


function run_task(::Type{Val{:kpoints}}, ::Type{Val{:make}}, args)
    out = args["o"] == "none" ? "KPOINTS" : args["o"]
    if args["par"] == "KSPACING"
        kspacing = parse(Float64, args["val"])
        write_kpoints(kspacing, args["poscar"], out=out)
    else
        Ns = parse.(Int64, split_line(args["N"], char=','))
        write_kpoints(Ns, out=out)
    end
end