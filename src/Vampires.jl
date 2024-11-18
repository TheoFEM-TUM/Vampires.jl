module Vampires

using OrderedCollections, Plots, LinearAlgebra, StatsBase, HDF5, ChunkSplitters, LsqFit, Unitful
import PhysicalConstants.CODATA2018: ħ, m_e
import Documenter: @doc

include("io/read_utils.jl")

# input
include("io/structure.jl"); include("io/eigenval.jl"); include("io/doscar.jl"); include("io/poscar.jl"); include("io/xdatcar.jl")
include("io/incar/incar_line.jl"); include("io/incar/incar.jl"); include("io/incar/incar_kw.jl"); include("io/incar/incar_tags.jl"); include("io/incar/incar_blocks.jl")
include("io/outcar.jl"); include("io/settings.jl")
include("io/w90_hr.jl")

# output
include("io/output/folder_management.jl"); include("io/output/bash_and_submission.jl");
include("io/output/kpoints.jl")

# calculations
include("calculations/energy/bandstructure.jl"); include("calculations/lattice/vectors.jl"); include("calculations/lattice/supercell.jl")
include("calculations/lattice/kspace.jl"); include("calculations/xdos/dos.jl"); # include("calculations/xdos/jdos.jl")
include("calculations/wannier90/hamiltonian.jl"); include("calculations/lattice/dynamics.jl")

# plotting
include("plotting/vamp_colors.jl")
include("plotting/energy/bandstructure.jl"); include("plotting/xdos/dos.jl"); include("plotting/recursive_plots/convergence.jl")

# tasks
# recursive.jl has to be the first include as it defines the @rcalc macro
include("tasks/recursive.jl")
include("tasks/incar_tasks.jl"); include("tasks/convergence_task.jl")
include("tasks/lattice_tasks.jl"); include("tasks/nscf_task.jl"); include("tasks/runscript_job_tasks.jl"); include("tasks/outcar_task.jl")
include("tasks/kpoint_tasks.jl"); include("tasks/eigenval_tasks.jl"); include("tasks/doscar_task.jl")
include("tasks/w90_tasks.jl"); include("tasks/xdatcar_tasks.jl"); include("tasks/settings_tasks.jl")

include("cli_interface.jl")

export Structure
export read_eigenval, read_doscar, Poscar, read_poscar, write_poscar, read_xdatcar, read_xdatcar_npt
export Incar, set_key!, remove_key!, findvalue, read_incar, write_incar
export add_incar_block!, rm_incar_block!
export read_value_from_outcar
export write_to_file, read_from_file, write_kpoints
export vcolors
export plot_bandstructure, plot_value_convergence

export convergence_create_subdirectories, nscf_create_subdirectories, write_run_script, add_path_to_folders, supercell_create_subdirectories
export get_bandgap, get_vbm_and_cbm, get_fermi_energy, get_effective_mass
export frac_to_cart, cart_to_frac, get_volume, get_bs, transform_primitive_cell
export compute_dos, convert_kspacing_to_kgrid

export run_task, run_task_recursive


# precompile
using PrecompileTools: @compile_workload, @setup_workload

@setup_workload begin
    A = Float64[1 2 3; 4 5 6; 7 8 9]
    v = Float64[1, 2, 3]
    task = Val{:incar}
    subtask = Val{:set}
    args = Dict("par"=>"ENCUT", "val"=>"250", "incar"=>"test/test_files/INCAR", "p"=>string(@__DIR__)*"/../", "block"=>"")
    args_list = ["--help"]
    @compile_workload begin
        redirect_stdout(Base.DevNull()) do
            run_task(task, subtask, args)
            main(args_list)
        end
    end
end
end # module