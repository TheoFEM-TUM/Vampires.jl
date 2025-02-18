@testset "VDOS" begin
    @testset "VDOS Masses" begin
        v = reshape([
            # atom 1 (4 timestep differences)
            15.0  10.0  24.0  9.0   # x
            3.0  1.0  24.0  22.0    # y
            1.0  1.0  7.0  -8.0     # z

            # atom 2 (4 timestep differences)
            15.0  10.0  24.0  9.0   # x
            3.0  1.0  24.0  22.0    # y
            1.0  1.0  7.0  -8.0     # z
        ], 3, 2, 4)
        vdos = Vampires.compute_vdos(v, 0.1, atom_names=["Ga", "As"])
        # TODO: add test
    end
end

@testset "VDOS Computation" begin
    n_atoms = 2
    n_dims = 3
    n_timesteps = 1000
    timestep = 1.0  # fs
    atom_names = ["H", "O"]
    velocities = randn(n_dims, n_atoms, n_timesteps) * 0.1  # generate random data in m/ps

    @testset "Full Method" begin
        ω, S = compute_vdos(velocities, timestep; method="full", atom_names=atom_names)
        # check dimensions
        @test length(ω) == n_timesteps
        @test length(S) == n_timesteps
        @test all(ustrip.(ω) .>= 0.0)
        @test maximum(S) ≈ 1.0
    end

    @testset "compute_vdos tests with value comparisons" begin
        # Mock data
        v = [0.1 0.2 0.3 0.4 0.5;
             0.2 0.3 0.4 0.5 0.6;
             0.3 0.4 0.5 0.6 0.7] |> reshape(3, 1, :)  # 3 directions, 1 atom, 5 timesteps
        timestep = 1.0  # 1 fs
        atom_names = ["H"]  # Single atom (Hydrogen)

        # Expected results
        expected_ω = [0.0, 3333.333333, 6666.666667, 10000.0]  # Known frequencies in cm^-1
        expected_S = [1.0, 0.5, 0.2, 0.1]                      # Mock normalized spectral density

        # Call the function
        ω, S = compute_vdos(v, timestep; atom_names=atom_names)

        # Tests for frequencies
        @test isapprox.(ω, expected_ω, atol=1e-6) |> all  # Compare frequencies within tolerance
        @test length(ω) == length(expected_ω)            # Length should match expected

        # Tests for spectral density
        @test isapprox.(S, expected_S, atol=1e-6) |> all  # Compare spectral density values
        @test length(S) == length(expected_S)            # Length should match expected

        # Edge case: Empty atom_names
        v_empty = v  # Same velocity data
        expected_ω_empty = expected_ω
        expected_S_empty = expected_S

        ω_empty, S_empty = compute_vdos(v_empty, timestep; atom_names=[])
        @test isapprox.(ω_empty, expected_ω_empty, atol=1e-6) |> all
        @test isapprox.(S_empty, expected_S_empty, atol=1e-6) |> all
    end

    @testset "Full Method GaAs" begin
        # TODO: compare actual values with dat file
    end

    # Test unsupported method
    @testset "Unsupported Method" begin
        @test_throws ErrorException compute_vdos(velocities, timestep; method="zero_padding", atom_names=atom_names)
    end
end


