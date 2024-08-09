"""
list of available tasks:

supercell
    make: create a supercell POSCAR file from an existing POSCAR file
    sample: create folders that each contains one snapshot from an XDATCAR file and other VASP input files
"""


function run_task(::Type{Val{:supercell}}, ::Type{Val{:make}}, args)
    poscar = read_poscar(args["p"]*args["poscar"])
    N = occursin(',', args["N"]) ? split_line(args["N"], char=',') : args["N"]
    N = parse.(Int64, N)
    sc_poscar = transform_primitive_cell(poscar, N)
    filename = args["o"] == "none" ? "SC_POSCAR" : args["o"]
    write_poscar(sc_poscar, filename=args["p"]*filename)
end

function run_task(::Type{Val{:supercell}}, ::Type{Val{:sample}}, args)
    poscar = args["p"]*args["poscar"]
    xdatcar = args["p"]*args["xdatcar"]
    Ns = parse.(Int64, split_line(args["N"], char=','))
    N, Nmin = length(Ns) > 1 ? Ns : (1, Ns[1])
    supercell_create_subdirectories(args["p"], xdatcar, poscar, N, method=args["method"], Nmin=Nmin)
end