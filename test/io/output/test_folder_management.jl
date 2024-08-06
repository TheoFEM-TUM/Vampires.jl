path = test_file_path*"param_test/"

@testset "convergence ENCUT" begin
    keyword = "ENCUT"
    values = ["300", "350", "400"]
    convergence_create_subdirectories(keyword, values; path=path, verbose=false)
    for (folder, value) in zip(keyword * "_" .* values, values)
        @test "INCAR" in readdir(path*folder) && "KPOINTS" in readdir(path*folder) && "POSCAR" in readdir(path*folder) && "POTCAR" in readdir(path*folder)
        incar_ = read_incar(path*folder*"/INCAR")
        @test findvalue(incar_, keyword) == value
        rm(path*folder, recursive=true)
    end
end

@testset "convergence kgrid" begin
    keyword = "kgrid"
    values = ["3", "5", "7"]

    # Test Gamma-centered grid
    convergence_create_subdirectories(keyword, values; path=path, verbose=false)
    for (folder, value) in zip(keyword * "_" .* values, values)
        @test "INCAR" in readdir(path*folder) && "KPOINTS" in readdir(path*folder) && "POSCAR" in readdir(path*folder) && "POTCAR" in readdir(path*folder)
        lines = Vampires.open_and_read(path*folder*"/KPOINTS")
        @test split_line(lines[3]) == ["Gamma"]
        @test split_line(lines[4]) == [value, value, value]
        rm(path*folder, recursive=true)
    end

    # Test Monkhorst-Pack grid
    convergence_create_subdirectories(keyword, values; path=path, verbose=false, method="Monkhorst-Pack")
    for (folder, value) in zip(keyword * "_" .* values, values)
        @test "INCAR" in readdir(path*folder) && "KPOINTS" in readdir(path*folder) && "POSCAR" in readdir(path*folder) && "POTCAR" in readdir(path*folder)
        lines = Vampires.open_and_read(path*folder*"/KPOINTS")
        @test split_line(lines[3]) == ["Monkhorst-Pack"]
        @test split_line(lines[4]) == [value, value, value]
        rm(path*folder, recursive=true)
    end
end

@testset "NSCF" begin
    nscf_create_subdirectories(path, "KPOINTS,KPOINTS_bands", verbose=false)
    scf_incar = read_incar(path*"scf/INCAR")
    @test findvalue(scf_incar, "ISTART") == "0"
    @test findvalue(scf_incar, "LCHARG") == "True"

    nscf_incar = read_incar(path*"nscf/INCAR")
    @test findvalue(nscf_incar, "ICHARG") == "11"
    @test findvalue(nscf_incar, "LCHARG") == "False"

    @test Vampires.open_and_read(path*"scf/POSCAR") == Vampires.open_and_read(path*"nscf/POSCAR")
    @test Vampires.open_and_read(path*"scf/POTCAR") == Vampires.open_and_read(path*"nscf/POTCAR")
    @test Vampires.open_and_read(path*"scf/KPOINTS") ≠ Vampires.open_and_read(path*"nscf/KPOINTS")
    @test Vampires.open_and_read(path*"scf/KPOINTS") == Vampires.open_and_read(path*"KPOINTS")
    @test Vampires.open_and_read(path*"nscf/KPOINTS") == Vampires.open_and_read(path*"KPOINTS_bands")

    rm(path*"scf", recursive=true); rm(path*"nscf", recursive=true)
end
