@testset "Supercell sample" begin
    args = Vampires.parse_commandline(ARGS)
    args["p"] = joinpath(@__DIR__, "test_files")
    args["xdatcar"] = "XDATCAR_gaas"
    args["poscar"] = "SC_POSCAR"
    args["kpoints"] = "KPOINTS_1"
    args["incar"] = "INCAR_1"
    args["N"] = "2"

    @run_task supercell sample args

    # Test 1: Test that the number of folders is equal to N
    @test count(file->occursin("config", file), Vampires.readfolders(joinpath(@__DIR__, "test_files"))) == 2

    # Test 2: Test that all input files are in each folder
    input_in_folder = map(Vampires.readfolders(joinpath(@__DIR__, "test_files"))) do folder
        path = readdir(joinpath(@__DIR__, "test_files", folder))
        if occursin("config", folder)
            return "INCAR" ∈ path && "KPOINTS" ∈ path && "POTCAR" ∈ path && "POSCAR" ∈ path
        end
        true
    end
    @test all(input_in_folder)

    for file in readdir(joinpath(@__DIR__, "test_files"))
        if occursin("config", file)
            rm(joinpath(@__DIR__, "test_files", file), recursive=true)
        end
    end
end