@testset "POSCAR tasks" begin
    # Test 1: Test read task
    args = Dict{String, Union{String, Bool}}()
    args["p"] = joinpath(@__DIR__, "test_files")
    args["poscar"] = "POSCAR_gaas"
    poscar = read_poscar(joinpath(args["p"], args["poscar"]))
    keys, values = run_task(Val{Symbol("poscar")}, Val{Symbol("read")}, args)
    @test values[1] == poscar.lattice
    @test values[2] == poscar.rs_atom
    @test values[3] == poscar.atom_types

    # Test 2: test recursive read to file output
    args["r"] = true
    args["v"] = false
    args["o"] = "poscars.h5"
    args["reduce"] = "none"
    keys, values = run_task_recursive(Val{Symbol("poscar")}, Val{Symbol("read")}, args)
    Vampires.task_output(keys, values, args)
    data_correct_in_file = map(1:3) do i
        [h5read("poscars.h5", "lattice")[:, :, i] == poscar.lattice,
        h5read("poscars.h5", "atom_types")[:, i] == poscar.atom_types,
        h5read("poscars.h5", "positions")[:, :, i] == poscar.rs_atom]
    end
    @test all(vcat(data_correct_in_file...))
    rm("poscars.h5")
end