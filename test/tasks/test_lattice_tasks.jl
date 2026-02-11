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

@testset "Supercell rattle" begin
    args = Vampires.parse_commandline(ARGS)
    args["p"] = joinpath(@__DIR__, "test_files")
    args["poscar"] = "SC_POSCAR"
    args["o"] = "XDATCAR_test"

    # Read original positions
    input_file = joinpath(args["p"], args["poscar"])
    poscar = read_poscar(input_file)
    orig_positions = frac_to_cart(poscar.positions, poscar.lattice)
    mass_dict = Dict{String, Float64}()
    for type in poscar.atom_names
        mass = elements[Symbol(type)].atomic_mass
        mass_dict[type] = mass / unit(mass)
    end
    mass_min = minimum(values(mass_dict))

    # Test different N values
    for N in ("1", "3")
        args["N"] = N
        @run_task supercell rattle args

        output_file = joinpath(args["p"], args["o"])
        @test isfile(output_file)

        xd = read_xdatcar(output_file)
        @test size(xd.positions, 3) == parse(Int, N)

        # Check that max displacement is not exceeded
        for n in 1:parse(Int, N)
            new_pos = frac_to_cart(xd.positions[:,:,n], xd.lattice)
            for i in axes(orig_positions, 2)
                disp = norm(new_pos[:,i] - orig_positions[:,i])
                # compute maximum allowed sigma for this atom
                sigma_i = 0.10 # default sigma
                sigma_i *= (mass_min / mass_dict[poscar.atom_types[i]])^0.8  # default alpha
                @test disp <= 3*sigma_i * 1.01  # allow tiny numerical tolerance
            end
        end
        rm(output_file)
    end

    # Test different methods
    for method in ("gaussian", "uniform")
        args["N"] = "2"
        args["method"] = method
        @run_task supercell rattle args

        output_file = joinpath(args["p"], args["o"])
        @test isfile(output_file)

        xd = read_xdatcar(output_file)
        @test size(xd.positions, 3) == 2

        for n in 1:2
            new_pos = frac_to_cart(xd.positions[:,:,n], xd.lattice)
            for i in axes(orig_positions, 2)
                disp = norm(new_pos[:,i] - orig_positions[:,i])
                sigma_i = 0.10 * (mass_min / mass_dict[poscar.atom_types[i]])^0.8
                @test disp <= 3*sigma_i * 1.01
            end
        end
        rm(output_file)
    end

    # Test custom rattle_cell parameters
    args["N"] = "2"
    args["method"] = "gaussian"
    args["par"] = "sigma_min,sigma_max,alpha"
    args["val"] = "0.01,0.05,0.8"
    @run_task supercell rattle args

    output_file = joinpath(args["p"], args["o"])
    @test isfile(output_file)

    xd = read_xdatcar(output_file)
    @test size(xd.positions, 3) == 2

    for n in 1:2
        new_pos = frac_to_cart(xd.positions[:,:,n], xd.lattice)
        for i in axes(orig_positions, 2)
            disp = norm(new_pos[:,i] - orig_positions[:,i])
            sigma_i = 0.05 * (mass_min / mass_dict[poscar.atom_types[i]])^0.8
            @test disp <= 3*sigma_i * 1.01
        end
    end
    rm(output_file)
end