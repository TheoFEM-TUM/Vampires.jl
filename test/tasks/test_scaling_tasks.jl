path = test_file_path*"param_test/"

@testset "Strong Scaling Tests" begin
    # redirect_stdout(Base.DevNull()) do
        # Define base arguments
        args = Vampires.parse_commandline(ARGS)
        args["p"] = path
        args["outcar"] = "OUTCAR"
        args["N"] = "2"

        # --- Test 1: CPU Strong Scaling ---
        @testset "CPU Strong Scaling" begin
            args["subtask"] = "cpu"
            args["kpar"] = "1,2,4"
            args["ncore"] = "8,4,2"
            args["ext_par_file"] = joinpath(test_file_path, "extended_parameter_file")
            args["block"] = "batch_file_cpu"

            run_task(Val{Symbol("strong_scaling")}, Val{Symbol("cpu")}, args)

            for (i, kpar, ncore) in zip(1:3, [1, 2, 4], [8, 4, 2])
                folder = joinpath(args["p"], "strong_scaling_$(i)_cpu")
                @test isdir(folder)
                @test "INCAR" in readdir(folder)

                incar = read_incar(joinpath(folder, "INCAR"))
                @test findvalue(incar, "KPAR") == string(kpar)
                @test findvalue(incar, "NCORE") == string(ncore)
            end
        end

        # --- Test 2: GPU Strong Scaling ---
        @testset "GPU Strong Scaling" begin
            args["subtask"] = "gpu"
            args["nsim"] = "8,4,2"
            args["block"] = "batch_file_gpu"

            run_task(Val{Symbol("strong_scaling")}, Val{Symbol("gpu")}, args)

            for (i, kpar, nsim) in zip(1:3, [1, 2, 4], [8, 4, 2])
                folder = joinpath(args["p"], "strong_scaling_$(i)_gpu")
                @test isdir(folder)
                @test "INCAR" in readdir(folder)

                incar = read_incar(joinpath(folder, "INCAR"))
                @test findvalue(incar, "KPAR") == string(kpar)
                @test findvalue(incar, "NSIM") == string(nsim)
            end
        end

        for i in 1:3
            folder = joinpath(args["p"], "strong_scaling_$(i)_gpu")
            cp(joinpath(test_file_path, "OUTCAR_gaas"), joinpath(folder, "OUTCAR"), force=true)
            folder = joinpath(args["p"], "strong_scaling_$(i)_cpu")
            cp(joinpath(test_file_path, "OUTCAR_gaas"), joinpath(folder, "OUTCAR"), force=true)
        end
        # --- Test 3: Read Strong Scaling Results ---
        @testset "Read Strong Scaling Results" begin
                args["p"] = path
                out = run_task(Val{Symbol("strong_scaling")}, Val{Symbol("read")}, args)
                @test haskey(out, :core_n) || haskey(out, :gpu_m)
                @test haskey(out, :time_n) || haskey(out, :time_m)
        end

        # --- Test 4: Plot Strong Scaling Results ---
        @testset "Plot Strong Scaling Results" begin
            run_task(Val{Symbol("strong_scaling")}, Val{Symbol("plot")}, args)
            @test isfile("cpu_plot.png") || isfile("gpu_plot.png") || isfile("gpu_cpu_plot.png")
        end

        # Cleanup generated files
        for i in 1:3
            rm(joinpath(args["p"], "strong_scaling_$(i)_cpu"), recursive=true, force=true)
            rm(joinpath(args["p"], "strong_scaling_$(i)_gpu"), recursive=true, force=true)
        end
        rm("cpu_plot.png", force=true)
        rm("gpu_plot.png", force=true)
        rm("gpu_cpu_plot.png", force=true)
    #end
end
