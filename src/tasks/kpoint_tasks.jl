"""
list of available tasks:

kpoints
    make: generate a kpoint file for a certain grid size or kspacing, respectively.
"""


function run_task(::Type{Val{:kpoints}}, ::Type{Val{:make}}, args)
    out = args["o"] == "none" ? "KPOINTS" : args["o"]
    gamma_centered = lowercase(method[1]) == 'm' ? false : true
    if args["par"] == "KSPACING"
        kspacing = parse(Float64, args["val"])
        write_kpoints(kspacing, args["poscar"], out=out, gamma_centered=gamma_centered)
    else
        Ns = parse.(Int64, split_line(args["N"], char=','))
        write_kpoints(Ns, out=out, gamma_centered=gamma_centered)
    end
end