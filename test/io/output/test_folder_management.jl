path = test_file_path*"param_test/"

@testset "convergence" begin
    keyword = "ENCUT"
    values = ["300", "350", "400"]
    convergence_create_subdirectories(keyword, values; path=path, verbose=false)
    for (folder, value) in zip(keyword * "_" .* values, values)
        @test "INCAR" in readdir(path*folder) && "KPOINTS" in readdir(path*folder) && "POSCAR" in readdir(path*folder) && "POTCAR" in readdir(path*folder)
        incar_ = read_incar(path*folder*"/INCAR")
        @test get_value_for_keyword(keyword, incar_) == value
        rm(path*folder, recursive=true)
    end
end

@testset "NSCF" begin
    nscf_create_subdirectories(path, "KPOINTS,KPOINTS_bands", verbose=false)
    scf_incar = read_incar(path*"scf/INCAR")
    @test get_value_for_keyword("ISTART", scf_incar) == "0"
    @test get_value_for_keyword("LCHARG", scf_incar) == "True"

    nscf_incar = read_incar(path*"nscf/INCAR")
    @test get_value_for_keyword("ICHARG", nscf_incar) == "11"
    @test get_value_for_keyword("LCHARG", nscf_incar) == "False"

    @test Vampires.open_and_read(path*"scf/POSCAR") == Vampires.open_and_read(path*"nscf/POSCAR")
    @test Vampires.open_and_read(path*"scf/POTCAR") == Vampires.open_and_read(path*"nscf/POTCAR")
    @test Vampires.open_and_read(path*"scf/KPOINTS") ≠ Vampires.open_and_read(path*"nscf/KPOINTS")
    @test Vampires.open_and_read(path*"scf/KPOINTS") == Vampires.open_and_read(path*"KPOINTS")
    @test Vampires.open_and_read(path*"nscf/KPOINTS") == Vampires.open_and_read(path*"KPOINTS_bands")

    rm(path*"scf", recursive=true); rm(path*"nscf", recursive=true)
end
