using Vampires, Test, LinearAlgebra

global test_file_path = string(@__DIR__) * "/test_files/"

include("io/test_read_utils.jl")

@testset "io" begin
    include("io/test_incar_line.jl")
    include("io/test_incar.jl")
    include("io/test_eigenval.jl")
    include("io/test_doscar.jl")
    include("io/test_poscar.jl")
    include("io/test_xdatcar.jl")
    include("io/test_outcar.jl")
    include("io/test_extended_config.jl")
end

@testset "io/output" begin
    include("io/output/test_folder_management.jl")
    include("io/output/test_bash_and_submission.jl")
end

@testset "tasks" begin
    include("tasks/test_cli.jl")
    include("tasks/test_recursive.jl")
end

@testset "calculations" begin
    include("calculations/test_bandgap.jl")
    include("calculations/test_vectors.jl")
    include("calculations/test_supercell.jl")
    include("calculations/test_kspace.jl")
    include("calculations/test_hamiltonian.jl")
end

@testset "xdos" begin
    include("xdos/test_dos.jl")
end