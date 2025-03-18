@testset "EIGENVAL read" begin
    # Test 1: Test read task
    args = Dict{String, Union{String, Bool}}()
    args["p"] = joinpath(@__DIR__, "test_files")
    args["eigenval"] = "EIGENVAL_gaas"
    args["par"] = "none"
    kp, Es, occs = read_eigenval(joinpath(args["p"], args["eigenval"]))
    out = @run_task eigenval read args
    @test out.kpoints == kp
    @test out.eigenvalues == Es
    @test out.occupations == occs

    # Test 2: Test recursive mode
    args["r"] = true
    args["v"] = false
    args["o"] = "eigenvals.h5"
    args["reduce"] = "none"
    out = @run_task_recursive eigenval read args
    Vampires.task_output(out, args)
    data_correct_in_file = map(1:3) do i
        [h5read("eigenvals.h5", "kpoints")[:, :, i] == kp,
        h5read("eigenvals.h5", "eigenvalues")[:, :, i] == Es,
        h5read("eigenvals.h5", "occupations")[:, :, i] == occs]
    end
    @test all(vcat(data_correct_in_file...))
    rm("eigenvals.h5")

    # Test 3: Test bandgap read
    args["par"] = "bandgap"
    out = @run_task eigenval read args
    @test out.bandgap == 0.5953680000000001

    # Test 4 Test recursive bandgap read
    args["reduce"] = "mean"
    args["o"] = "bandgap.h5"
    out = @run_task_recursive eigenval read args
    @test out.bandgap == [0.5953680000000001, 0.5953680000000001, 0.5953680000000001]
    Vampires.task_output(out, args)
    @test h5read("bandgap.h5", "mean_bandgap") == 0.5953680000000001 
    rm("bandgap.h5")
end