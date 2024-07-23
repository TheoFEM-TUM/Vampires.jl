module Vampires

using OrderedCollections, ArgParse, Plots, BenchmarkTools, CSV, LinearAlgebra

include("io/read_utils.jl")
# input
include("io/input/eigenval.jl"); include("io/input/doscar.jl"); include("io/input/poscar.jl"); include("io/input/xdatcar.jl")
include("io/input/incar.jl"); include("io/input/outcar.jl")

# output
include("io/output/incar.jl")

# calculations
include("calculations/energy/bandstructure.jl")
include("calculations/xdos/dos.jl"); # include("calculations/xdos/jdos.jl")

# plotting
include("plotting/energy/bandstructure.jl"); include("plotting/xdos/dos.jl"); 

# tasks
# recursive.jl has to be the first include as it defines the @rcalc macro
include("tasks/recursive.jl")
include("tasks/modify_task.jl"); include("tasks/calculation_task.jl"); include("tasks/plot_task.jl"); include("tasks/convergence_task.jl")
include("tasks/run_script.jl")

include("cli_interface.jl")

export read_eigenval, read_doscar, read_incar, set_keyword!, write_incar, Poscar, read_poscar, write_poscar, read_xdatcar
export get_value_for_keyword, change_incar!, read_value_from_file
export write_to_file, read_from_file
export plot_bandstructure

export convergence_create_subdirectories, get_bandgap, get_vbm_and_cbm, get_fermi_energy
export compute_dos

end # module
