@testset "OUTCAR tasks" begin
    args = Vampires.parse_commandline(ARGS)
    args["p"] = test_file_path
    args["contcar"] = "CONTCAR_si"

    args["par"] = "lattice"
    out = run_task(Val{Symbol("contcar")}, Val{Symbol("read")}, args)
    @test out.α ≈ 60
    @test out.β ≈ 60
    @test out.γ ≈ 60
    @test isapprox(out.a, 3.84, rtol=1e-3)
    @test isapprox(out.b, 3.84, rtol=1e-3)
    @test isapprox(out.c, 3.84, rtol=1e-3)
    @test isapprox(out.volume, 40.03, rtol=1e-3)
end