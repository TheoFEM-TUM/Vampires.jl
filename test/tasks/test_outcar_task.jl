@testset "OUTCAR tasks" begin
    args = Vampires.parse_commandline(ARGS)
    args["p"] = joinpath(@__DIR__, "test_files/")
    args["outcar"] = "OUTCAR_gaas"
    
    # Test 1: test to read bandgap from OUTCAR
    args["par"] = "bandgap"
    out = run_task(Val{Symbol("outcar")}, Val{Symbol("read")}, args)
    @test out.bandgap == 0.5946000000000002

    args["o"] = "bandgap.h5"
    Vampires.task_output(out, args)
    @test h5read("bandgap.h5", "bandgap") == 0.5946000000000002
    rm("bandgap.h5")

    # Test 2: test to read TOTEN from OUTCAR
    args["par"] = "free energy"
    args["o"] = "toten.h5"
    
    out = run_task(Val{Symbol("outcar")}, Val{Symbol("read")}, args) 
    @test out.var"free energy" == [3.61103872, -8.30542697, -8.42796620, -8.42817101, -8.42817102, -8.28555592, -8.25135154, -8.25102197, -8.25125818, -8.25135131, -8.25135668]
    
    args["reduce"] = "last"
    Vampires.task_output(out, args)
    @test h5read("toten.h5", "last_free energy") == -8.25135668
    rm("toten.h5")

    args["reduce"] = "diff"
    Vampires.task_output(out, args)
    @test length(h5read("toten.h5", "diff_free energy")) == length(out.var"free energy")-1
    @test h5read("toten.h5", "diff_free energy")[end] < 1e-5
    rm("toten.h5")

    # Test 3: test OUTCAR recursive mode
    args["par"] = "forces"
    args["o"] = "forces.h5"
    args["r"] = true
    args["reduce"] = "maxdiff"
    out = run_task_recursive(Val{Symbol("outcar")}, Val{Symbol("read")}, args)
    @test string.(keys(out)) == ("positions", "forces")
    @test size.(values(out)) == ((3, 2, 1, 3), (3, 2, 1, 3))

    Vampires.task_output(out, args)
    @test h5read("forces.h5", "maxdiff_forces") == 0
    @test h5read("forces.h5", "maxdiff_positions") == 0
    rm("forces.h5")

    args["reduce"] = "mean."
    args["o"] = "mean.h5"
    Vampires.task_output(out, args)

    @test h5read("mean.h5", "mean_forces") == [0., 0., 0.]
    @test h5read("mean.h5", "mean_positions") == [0.7062500000000002, 0.7062500000000002, 0.7062500000000002]
    rm("mean.h5")

    # Test 4: test OUTCAR recursive total energy
    args["par"] = "free  energy"
    args["o"] = "toten.h5"
    args["reduce"] = "none"
    keys, values = run_task_recursive(Val{Symbol("outcar")}, Val{Symbol("read")}, args)
    Vampires.task_output(keys, values, args)
    @test h5read("toten.h5", "free  energy") == [-8.25135668, -8.25135668, -8.25135668]
    rm("toten.h5")
end