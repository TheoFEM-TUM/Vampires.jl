module Vampires

using OrderedCollections, ArgParse, Plots, BenchmarkTools, CSV, LinearAlgebra, StatsBase

include("io/read_utils.jl")
# input
include("io/input/eigenval.jl"); include("io/input/doscar.jl"); include("io/input/poscar.jl"); include("io/input/xdatcar.jl")
include("io/input/incar.jl"); include("io/input/incar_tags.jl"); include("io/input/incar_blocks.jl");include("io/input/outcar.jl")
include("io/input/w90_hr.jl")

# output
include("io/output/incar.jl"); include("io/output/folder_management.jl"); include("io/output/bash_and_submission.jl"); 
include("io/output/kpoints.jl")

# calculations
include("calculations/energy/bandstructure.jl"); include("calculations/lattice/vectors.jl"); include("calculations/lattice/supercell.jl")
include("calculations/lattice/kspace.jl"); include("calculations/xdos/dos.jl"); # include("calculations/xdos/jdos.jl")
include("calculations/wannier90/hamiltonian.jl")

# plotting
include("plotting/energy/bandstructure.jl"); include("plotting/xdos/dos.jl"); include("plotting/recursive_plots/convergence.jl")

# tasks
# recursive.jl has to be the first include as it defines the @rcalc macro
include("tasks/recursive.jl")
include("tasks/incar_tasks.jl"); include("tasks/calculation_task.jl"); include("tasks/plot_task.jl"); include("tasks/convergence_task.jl")
include("tasks/lattice_tasks.jl"); include("tasks/nscf_task.jl"); include("tasks/run_script.jl"); include("tasks/outcar_task.jl")
include("tasks/kpoint_tasks.jl")

include("cli_interface.jl")

export read_eigenval, read_doscar, read_incar, set_keyword!, write_incar, Poscar, read_poscar, write_poscar, read_xdatcar
export get_value_for_keyword, change_incar!, read_value_from_outcar, add_incar_block!, rm_incar_block!, remove_keyword!
export write_to_file, read_from_file, write_kpoints
export plot_bandstructure, plot_value_convergence

export convergence_create_subdirectories, nscf_create_subdirectories, write_run_script, add_path_to_folders, supercell_create_subdirectories
export get_bandgap, get_vbm_and_cbm, get_fermi_energy
export frac_to_cart, cart_to_frac, get_volume, get_bs, transform_primitive_cell
export compute_dos, convert_kspacing_to_kgrid

export run_task, run_task_recursive

end # module
