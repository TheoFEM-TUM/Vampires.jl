using Vampires, Test, LinearAlgebra

global test_file_path = string(@__DIR__) * "/test_files/"

include("io/test_read_utils.jl")

@testset "io/input" begin
    include("io/input/test_eigenval.jl")
    include("io/input/test_doscar.jl")
    include("io/input/test_poscar.jl")
    include("io/input/test_xdatcar.jl")
    include("io/input/test_incar.jl")
    include("io/input/test_outcar.jl")    
end

@testset "io/output" begin
    include("io/output/test_folder_management.jl")
end

@testset "tasks" begin
    include("tasks/test_recursive.jl")
end

@testset "calculations" begin
    include("calculations/test_bandgap.jl")
    include("calculations/test_vectors.jl")
end

@testset "xdos" begin
    include("xdos/test_dos.jl")
end