@testset "EIGENVAL read" begin
    # Test 1: Test read task
    args = Dict{String, Union{String, Bool}}()
    args["p"] = joinpath(@__DIR__, "test_files")
    args["eigenval"] = "EIGENVAL_gaas"
    args["par"] = "none"
    kp, Es, occs = read_eigenval(joinpath(args["p"], args["eigenval"]))
    keys, values = run_task(Val{Symbol("eigenval")}, Val{Symbol("read")}, args)
    @test values[1] == kp
    @test values[2] == Es
    @test values[3] == occs

    # Test 2: Test recursive mode
    args["r"] = true
    args["v"] = false
    args["o"] = "eigenvals.h5"
    args["method"] = "none"
    keys, values = run_task_recursive(Val{Symbol("eigenval")}, Val{Symbol("read")}, args)
    Vampires.task_output(keys, values, args)
    data_correct_in_file = map(1:3) do i
        [h5read("eigenvals.h5", "kpoints")[:, :, i] == kp,
        h5read("eigenvals.h5", "eigenvalues")[:, :, i] == Es,
        h5read("eigenvals.h5", "occupations")[:, :, i] == occs]
    end
    @test all(vcat(data_correct_in_file...))
    rm("eigenvals.h5")

    # Test 3: Test bandgap read
    args["par"] = "bandgap"
    keys, values = run_task(Val{Symbol("eigenval")}, Val{Symbol("read")}, args)
    @test values[1] == 0.5953680000000001

    # Test 4 Test recursive bandgap read
    args["method"] = "mean"
    args["o"] = "bandgap.h5"
    keys, values = run_task_recursive(Val{Symbol("eigenval")}, Val{Symbol("read")}, args)
    @test values == [[0.5953680000000001], [0.5953680000000001], [0.5953680000000001]]
    Vampires.task_output(keys, values, args)
    @test h5read("bandgap.h5", "mean_bandgap") == 0.5953680000000001 
    rm("bandgap.h5")
end