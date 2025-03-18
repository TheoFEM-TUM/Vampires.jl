@testset "INCAR tests" begin
    redirect_stdout(Base.DevNull()) do
        args = Vampires.parse_commandline(ARGS)
        args["par"] = "ENCUT,ISMEAR,EDIFF"
        args["val"] = "250,0,1e-5"
        run_task(Val{Symbol("incar")}, Val{Symbol("make")}, args)

        # Test 1: Test INCAR generation
        out = run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args)
        @test string.(keys(out)) == ("ENCUT", "ISMEAR", "EDIFF")
        @test values(out) == ("250", "0", "1e-5")

        # Test 2: Test INCAR set
        args["par"] = "ENCUT"
        args["val"] = "350"
        run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)
        @test run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args).ENCUT == "350"

        # Test 3: INCAR set with num_wann
        @run_task incar set par=num_wann val=8
        @test (@run_task incar read par=num_wann).num_wann == "8"
        @test (@run_task incar read par=NUM_WANN).NUM_WANN == "8"
        @run_task incar set par=NUM_WANN val=12
        @test (@run_task incar read par=num_wann).num_wann == "12"

        # Test 4: Test INCAR rm
        args["par"] = "ENCUT"
        run_task(Val{Symbol("incar")}, Val{Symbol("rm")}, args)
        @test_throws KeyError run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args)[2] == []

        # Test 5: Test add block
        args["par"] = ""
        args["block"] = "Parallelization"
        run_task(Val{Symbol("incar")}, Val{Symbol("add")}, args)
        args["par"] = "NCORE,KPAR"
        out = run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args)
        @test string.(keys(out)) == ("NCORE", "KPAR")
        @test values(out) == ("1", "1")
        rm("INCAR")

        # Test 6: Recursive mode
        args["p"] = joinpath(@__DIR__, "test_files")
        args["par"] = "LPLANE,IBRION"
        args["val"] = "False,0"
        args["r"] = true
        run_task_recursive(Val{Symbol("incar")}, Val{Symbol("make")}, args)
        out = run_task_recursive(Val{Symbol("incar")}, Val{Symbol("read")}, args)
        @test string.(keys(out)) == ("LPLANE", "IBRION")
        @test out.LPLANE == ["False", "False", "False"]
        @test out.IBRION == ["0", "0", "0"]

        args["par"] = "KSPACING"
        args["val"] = "0.2"
        run_task_recursive(Val{Symbol("incar")}, Val{Symbol("set")}, args)
        out = run_task_recursive(Val{Symbol("incar")}, Val{Symbol("read")}, args)
        @test string.(keys(out)) == ("KSPACING",)
        @test out.KSPACING == ["0.2", "0.2", "0.2"]

        for folder in Vampires.readfolders(args["p"])
            rm(joinpath(args["p"], folder, "INCAR"))
        end
    end
end