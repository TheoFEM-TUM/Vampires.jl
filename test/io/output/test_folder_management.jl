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

@testset "StrongScaling" begin
    kpar_range = [1, 2, 4]
    ncore_nsim_range = [8, 4, 2]
    for keyword in ["CPU", "GPU"]
        strong_scaling_create_subdirectories(kpar_range, ncore_nsim_range; path=path, verbose=false, keyword=keyword, time=1, avail_gpus_per_node=4, avail_cpus_per_node=2)
        
        for (i, kpar, ncore_nsim) in zip(collect(1:length(kpar_range)), kpar_range, ncore_nsim_range)
            folder = "strong_scaling_$(i)_" * keyword
            @test "INCAR" in readdir(path*folder) && "KPOINTS" in readdir(path*folder) && "POSCAR" in readdir(path*folder) && "POTCAR" in readdir(path*folder)
            
            incar_ = read_incar(path*folder*"/INCAR")
            @test get_value_for_keyword("KPAR", incar_) == string(kpar)
            
            if keyword == "CPU"
                @test get_value_for_keyword("NCORE", incar_) == string(ncore_nsim)
            elseif keyword == "GPU"
                @test get_value_for_keyword("NSIM", incar_) == string(ncore_nsim)
            end

            rm(path*folder, recursive=true)
        end
    end
end

