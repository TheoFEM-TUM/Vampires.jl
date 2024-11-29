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

    @testset "Full Method GaAs" begin
        # TODO: compare actual values with dat file
    end

    # Test unsupported method
    @testset "Unsupported Method" begin
        @test_throws ErrorException compute_vdos(velocities, timestep; method="zero_padding", atom_names=atom_names)
    end
end


