module VaspTools

using OrderedCollections, ArgParse, Plots, BenchmarkTools, CSV, LinearAlgebra

include("read_utils.jl")
include("parser/eigenval.jl"); include("parser/doscar.jl"); include("parser/poscar.jl"); include("parser/xdatcar.jl")
include("parser/incar.jl")

include("calculations/energy/bandstructure.jl")
include("calculations/xdos/dos.jl"); # include("calculations/xdos/jdos.jl")

include("tasks/param_test.jl"); include("tasks/change_incar.jl"); include("tasks/eigenvalue_tasks.jl"); include("tasks/plot.jl")

include("cli_interface.jl")

include("plotting/energy/bandstructure.jl"); include("plotting/xdos/dos.jl"); 

export read_eigenval, read_doscar, read_incar, set_keyword!, write_incar, Poscar, read_poscar, write_poscar, read_xdatcar
export get_value_for_keyword, change_incar!
export write_to_file, read_from_file
export plot_bandstructure

export run_parameter_test, get_bandgap, get_vbm_and_cbm, get_fermi_energy
export compute_dos

end # module
