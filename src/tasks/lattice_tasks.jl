"""
list of available tasks:

supercell
    create: create a supercell POSCAR file from an existing POSCAR file
"""


function run_task(::Type{Val{:supercell}}, ::Type{Val{:create}}, args)
    poscar = read_poscar(args["p"]*args["poscar"])
    N = occursin(',', args["N"]) ? split_line(args["N"], char=',') : args["N"]
    N = parse.(Int64, N)
    sc_poscar = transform_primitive_cell(poscar, N)
    write_poscar(sc_poscar, filename=args["p"]*"SC_POSCAR") #TODO: args["o"]?
end