@testset "W90 read" begin
    args = Vampires.get_default_args()
    args["p"] = joinpath(@__DIR__, "test_files")

    for folder in ["r1", "r2", "r3"]
        cp(joinpath(args["p"], "wannier90_hr.dat"), joinpath(args["p"], folder, "wannier90_hr.dat"), force=true)
    end

    # Test 1: Test standard read
    Hr, Rs, deg = read_hrdat(joinpath(args["p"], "wannier90_hr.dat"))
    keys, values = run_task(Val{Symbol("w90_hr")}, Val{Symbol("read")}, args)

    @test keys == ["Hr", "Rs", "degeneracies"]
    @test Hr == values[1]
    @test Rs == values[2]
    @test deg == values[3]

    # Test 2: Test recursive read
    args["o"] = "w90.h5"
    args["r"] = true
    keys, values = run_task_recursive(Val{Symbol("w90_hr")}, Val{Symbol("read")}, args)
    Vampires.task_output(keys, values, args)

    @test all([h5read("w90.h5", "Hr")[:, :, :, i] == Hr for i in 1:3])
    @test all([h5read("w90.h5", "Rs")[:, :, i] == Rs for i in 1:3])
    @test all([h5read("w90.h5", "degeneracies")[:, i] == deg for i in 1:3])

    rm("w90.h5")
    for folder in ["r1", "r2", "r3"]
        rm(joinpath(args["p"], folder, "wannier90_hr.dat"), force=true)
    end
end