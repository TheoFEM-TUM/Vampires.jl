using Vampires, Test, LinearAlgebra, HDF5, Plots, Unitful

global test_file_path = joinpath(string(@__DIR__), "test_files/")

include("io/test_read_utils.jl")
include("io/test_structure.jl")

@testset "io" begin
    include("io/test_incar_line.jl")
    include("io/input/test_incar.jl")
    include("io/input/test_eigenval.jl")
    include("io/input/test_doscar.jl")
    include("io/input/test_poscar.jl")
    include("io/input/test_xdatcar.jl")
    include("io/input/test_lammps.jl")
    include("io/input/test_outcar.jl")
    include("io/input/test_contcar.jl")
    include("io/input/test_extended_config.jl")
    include("io/plotting/test_colors.jl")
    include("io/test_command_log.jl")
end

@testset "io/output" begin
    include("io/output/test_folder_management.jl")
    include("io/output/test_bash_and_submission.jl")
end

@testset "tasks" begin
    include("tasks/test_cli.jl")
    include("tasks/test_incar_tasks.jl")
    include("tasks/test_outcar_task.jl")
    include("tasks/test_poscar_task.jl")
    include("tasks/test_eigenval_task.jl")
    include("tasks/test_w90_tests.jl")
    include("tasks/test_scaling_tasks.jl")
end

@testset "calculations" begin
    include("calculations/test_bandstructure.jl")
    include("calculations/test_vectors.jl")
    include("calculations/test_supercell.jl")
    include("calculations/test_kspace.jl")
    include("calculations/test_hamiltonian.jl")
    include("calculations/test_dynamics.jl")
    include("calculations/test_numerics.jl")
end

@testset "xdos" begin
    include("xdos/test_dos.jl")
    include("xdos/test_vdos.jl")
end