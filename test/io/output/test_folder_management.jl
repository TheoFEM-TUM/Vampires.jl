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
    nscf_create_subdirectories(path, "KPOINTS,KPOINTS_bands", "INCAR", verbose=false)
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

@testset "split_path_at_folder tests" begin
    # Test 1: Folder found in path
    result = Vampires.split_path_at_folder("/home/user/project/folder/subfolder", "project")
    @test result == "folder/subfolder"

    # Test 2: Folder is the last element
    result = Vampires.split_path_at_folder("/home/user/project", "project")
    @test result == ""

    # Test 3: Folder not found in path (should throw error)
    @test_throws ErrorException begin
        Vampires.split_path_at_folder("/home/user/project/folder", "nonexistent")
    end

    # Test 4: Folder found at the beginning of the path
    result = Vampires.split_path_at_folder("/home/user/project/folder/subfolder", "home")
    @test result == "user/project/folder/subfolder"

    # Test 5: Folder is the second element in the path
    result = Vampires.split_path_at_folder("/home/user/project/folder", "user")
    @test result == "project/folder"

    # Test 6: Folder name is a substring of a path segment (check for exact match)
    result = Vampires.split_path_at_folder("/home/user/project/folder", "proj")
    @test result == "folder"
end

@testset "StrongScaling" begin
    kpar_range = [1, 2, 4]
    ncore_nsim_range = [8, 4, 2]
    for keyword in ["cpu", "gpu"]
        strong_scaling_create_subdirectories_VASP(kpar_range, ncore_nsim_range; path=path, verbose=false, keyword=keyword, time=1, avail_gpus_per_node=4, avail_cpus_per_node=2)

        for (i, kpar, ncore_nsim) in zip(collect(1:length(kpar_range)), kpar_range, ncore_nsim_range)
            folder = "strong_scaling_$(i)_" * keyword
            @test "INCAR" in readdir(path*folder) && "KPOINTS" in readdir(path*folder) && "POSCAR" in readdir(path*folder) && "POTCAR" in readdir(path*folder)

            incar = read_incar(path*folder*"/INCAR")
            @test findvalue(incar, "KPAR") == string(kpar)

            if keyword == "cpu"
                @test findvalue(incar, "NCORE") == string(ncore_nsim)
            elseif keyword == "gpu"
                @test findvalue(incar, "NSIM") == string(ncore_nsim)
            end

            rm(path*folder, recursive=true)
        end
    end
end