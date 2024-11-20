@testset "MSD" begin
    @testset "Single TS" begin
        # define a cubic lattice, initial positions (r₀), and displaced positions (rᵢ)
        lattice = [1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0]

        r₀ = [0.1 0.5 0.9; 0.2 0.6 0.8; 0.3 0.7 0.1]'
        rᵢ = reshape([0.15 0.45 0.95; 0.25 0.55 0.85; 0.35 0.75 0.15]', (3, 3, 1))

        msd, err = compute_msd(r₀, rᵢ, lattice)

        expected_msd = [0.0075]
        expected_err = [0.0]     # std is zero (one ts only)

        @test length(msd) == 1
        @test length(err) == 1
        @test abs(msd[1] - expected_msd[1]) < 1e-6
        @test abs(err[1] - expected_err[1]) < 1e-6
    end
    @testset "Multiple TS without PBCs" begin
        # define a cubic lattice, initial positions (r₀), and displaced positions (rᵢ)
        lattice = [10.0 0.0 0.0; 0.0 10.0 0.0; 0.0 0.0 10.0]
        r₀ = reshape([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9], 3, 3)
        rᵢ = reshape([0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 0.95,
                        0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0,
                        0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 0.95, 1.05], 3, 3, 3)

        msd, err = compute_msd(r₀, rᵢ, lattice)

        expected_msd = [0.0075, 0.03, 0.0675]
        expected_err = [0.0, 0.0, 0.0]

        @test isapprox(msd, expected_msd, atol=1e-6)
        @test isapprox(err, expected_err, atol=1e-6)
    end
    @testset "Single TS with PBC" begin
        # define a cubic lattice, initial positions (r₀), and displaced positions (rᵢ)
        lattice = [10.0 0.0 0.0; 0.0 10.0 0.0; 0.0 0.0 10.0]
        r₀ = reshape([0.1, 0.2, 9.975, 9.99, 0.5, 0.6, 0.7, 9.98, 0.3], 3, 3)
        rᵢ = reshape([0.15, 0.25, 0.025, 0.04, 0.55, 0.65, 0.75, 0.03, 0.35], 3, 3, 1)

        msd, err = compute_msd(r₀, rᵢ, lattice)

        expected_msd = [0.0075]
        expected_err = [0.0]

        @test isapprox(msd, expected_msd, atol=1e-6)
        @test isapprox(err, expected_err, atol=1e-6)
    end
    @testset "Multiple TSs with PBC" begin
        # define a cubic lattice, initial positions (r₀), and displaced positions (rᵢ)
        lattice = [10.0 0.0 0.0; 0.0 10.0 0.0; 0.0 0.0 10.0]
        r₀ = reshape([0.1, 9.99, 0.3, 9.97, 0.5, 0.6, 0.7, 0.89, 9.98], 3, 3)
        rᵢ = reshape([0.15, 0.04, 0.35, 0.02, 0.55, 0.65, 0.75, 0.94, 0.03,
                        0.2, 0.09, 0.4, 0.07, 0.6, 0.7, 0.8, 0.99, 0.08], 3, 3, 2)

        msd, err = compute_msd(r₀, rᵢ, lattice)

        expected_msd = [0.0075, 0.03]
        expected_err = [0.0, 0.0]

        @test isapprox(msd, expected_msd, atol=1e-6)
        @test isapprox(err,  expected_err, atol=1e-6)
    end
    @testset "orthorhombic lattice with PBC" begin
        # define an orthorhombic lattice, initial positions (r₀), and displaced positions (rᵢ)
        lattice = [2.0 0.0 0.0; 0.0 3.0 0.0; 0.0 0.0 4.0]
        r₀ = reshape([0.1, 1.9, 3.9, 1.2, 2.8, 0.1, 0.7, 0.5, 3.5], 3, 3)
        rᵢ = reshape([0.3, 2.1, 0.1, 1.4, 0.2, 3.9, 0.9, 0.8, 0.1], 3, 3, 1)

        msd, err = compute_msd(r₀, rᵢ, lattice)

        expected_msd = [0.283333]
        expected_err = [0.188768]

        @test isapprox(msd, expected_msd, atol=1e-6)
        @test isapprox(err,  expected_err, atol=1e-6)
    end
end
@testset "compute_velocities tests with PBCs" begin
    x = reshape([
        # atom 1 (5 timesteps)
        0.0 1.5 2.5 4.9 0.8   # x
        0.0 0.3 0.4 2.8 0.0   # y
        0.0 0.1 0.2 0.9 0.1   # z

        # atom 2 (5 timesteps)
        0.0 1.5 2.5 4.9 0.8   # x
        0.0 0.3 0.4 2.8 0.0   # y
        0.0 0.1 0.2 0.9 0.1   # z
    ], 3, 2, 5)

    δt = 0.1
    L = [5.0 0.0 0.0;
         0.0 5.0 0.0;
         0.0 0.0 5.0]

    # Expected result after applying PBCs
    v_expected = reshape([
        # atom 1 (4 timestep differences)
        15.0  10.0  24.0  9.0   # x
        3.0  1.0  24.0  22.0    # y
        1.0  1.0  7.0  -8.0     # z

        # atom 2 (4 timestep differences)
        15.0  10.0  24.0  9.0   # x
        3.0  1.0  24.0  22.0    # y
        1.0  1.0  7.0  -8.0     # z
    ], 3, 2, 4)

    v = compute_velocities(x, δt, L)
    @test isapprox(v, v_expected, atol=1e-6)
end
