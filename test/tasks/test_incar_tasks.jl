@testset "INCAR tests" begin
    redirect_stdout(Base.DevNull()) do
        args = Vampires.parse_commandline(ARGS)
        args["par"] = "ENCUT,ISMEAR,EDIFF"
        args["val"] = "250,0,1e-5"
        run_task(Val{Symbol("incar")}, Val{Symbol("make")}, args)
        
        # Test 1: Test INCAR generation
        keys, values = run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args)
        @test keys == ["ENCUT", "ISMEAR", "EDIFF"]
        @test values == ["250", "0", "1e-5"]

        # Test 2: Test INCAR set
        args["par"] = "ENCUT"
        args["val"] = "350"
        run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)
        @test run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args)[2] == ["350"]

        # Test 3: INCAR set with num_wann
        args["par"] = "num_wann"
        args["val"] = "8"
        run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)
        @test run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args)[2] == ["8"]
        args["par"] = "NUM_WANN"
        @test run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args)[2] == ["8"]

        # Test 4: Test INCAR rm
        args["par"] = "ENCUT"
        run_task(Val{Symbol("incar")}, Val{Symbol("rm")}, args)
        @test_throws KeyError run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args)[2] == []

        # Test 5: Test add block
        args["par"] = ""
        args["block"] = "Parallelization"
        run_task(Val{Symbol("incar")}, Val{Symbol("add")}, args)
        args["par"] = "NCORE,KPAR"
        keys, values = run_task(Val{Symbol("incar")}, Val{Symbol("read")}, args)
        @test keys == ["NCORE", "KPAR"]
        @test values == ["1", "1"]
        rm("INCAR")

        # Test 6: Recursive mode
        args["p"] = joinpath(@__DIR__, "test_files")
        args["par"] = "LPLANE,IBRION"
        args["val"] = "False,0"
        args["r"] = true
        run_task_recursive(Val{Symbol("incar")}, Val{Symbol("make")}, args)
        keys, values = run_task_recursive(Val{Symbol("incar")}, Val{Symbol("read")}, args)
        @test keys == ["LPLANE", "IBRION"]
        @test values == [["False", "0"], ["False", "0"], ["False", "0"]]
        
        args["par"] = "KSPACING"
        args["val"] = "0.2"
        run_task_recursive(Val{Symbol("incar")}, Val{Symbol("set")}, args)
        keys, values = run_task_recursive(Val{Symbol("incar")}, Val{Symbol("read")}, args)
        @test keys == ["KSPACING"]
        @test values == [["0.2"], ["0.2"], ["0.2"]]

        for folder in Vampires.readfolders(args["p"])
            rm(joinpath(args["p"], folder, "INCAR"))
        end
    end
end