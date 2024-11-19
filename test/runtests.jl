using Vampires, Test, LinearAlgebra, Plots

global test_file_path = string(@__DIR__) * "/test_files/"

include("io/test_read_utils.jl")

@testset "io" begin
    include("io/test_incar_line.jl")
    include("io/input/test_incar.jl")
    include("io/input/test_eigenval.jl")
    include("io/input/test_doscar.jl")
    include("io/input/test_poscar.jl")
    include("io/input/test_xdatcar.jl")
    include("io/input/test_outcar.jl")
    include("io/plotting/test_colors.jl")
end

@testset "io/output" begin
    include("io/output/test_folder_management.jl")
end

@testset "tasks" begin
    include("tasks/test_cli.jl")
    include("tasks/test_recursive.jl")
end

@testset "calculations" begin
    include("calculations/test_bandstructure.jl")
    include("calculations/test_vectors.jl")
    include("calculations/test_supercell.jl")
    include("calculations/test_kspace.jl")
    include("calculations/test_hamiltonian.jl")
    include("calculations/test_dynamics.jl")
end

@testset "xdos" begin
    include("xdos/test_dos.jl")
end