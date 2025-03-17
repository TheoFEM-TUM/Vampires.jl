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
        v = reshape([0.1 0.2 0.3 0.4;
             0.2 0.3 0.4 0.5;
             0.3 0.4 0.5 0.6], 3, 1, :)  # 3 directions, 1 atom, 4 timesteps
        timestep = 1.0  # 1 fs
        atom_names = String["H"]  # Single atom (Hydrogen)

        # Expected results
        expected_ω = [0.0, 3333.333333, 6666.666667, 10000.0]  # Known frequencies in cm^-1
        expected_ω = [0.0, 4765.201360, 9530.40272, 14295.60408]
        expected_S = [0.0, 1.0, 0.011827, 0.017728]                      # Mock normalized spectral density

        # Call the function
        ω, S = compute_vdos(v, timestep; atom_names=atom_names)
        # Tests for frequencies
        @test length(ω) == length(expected_ω)            # Length should match expected
        @test isapprox.(ustrip.(ω), expected_ω, atol=1e-6) |> all  # Compare frequencies within tolerance

        # Tests for spectral density
        @test isapprox.(ustrip.(S), expected_S, atol=1e-6) |> all  # Compare spectral density values
        @test length(S) == length(expected_S)            # Length should match expected

        # Edge case: Empty atom_names
        v_empty = v  # Same velocity data
        expected_ω_empty = expected_ω
        expected_S_empty = expected_S

        ω_empty, S_empty = compute_vdos(v_empty, timestep; atom_names=String[])
        @test isapprox.(ustrip.(ω_empty), expected_ω_empty, atol=1e-6) |> all
        @test isapprox.(ustrip.(S_empty), expected_S_empty, atol=1e-6) |> all
    end

    @testset "Full Method GaAs" begin
        xdat = read_xdatcar(test_file_path * "XDATCAR_gaas")
        vel = compute_velocities(xdat.positions, 1, xdat.lattice)
        ω, S = compute_vdos(vel, 1; method="full", atom_names=xdat.atom_types)
        @test S == read_from_file(test_file_path*"vdos_gaas_correct.dat")
        ω, S = lorentzian_broadening(ustrip.(ω), S, 0.4)
        @test S == read_from_file(test_file_path*"vdos_broadening_gaas_correct.dat")
    end

    # Test unsupported method
    @testset "Unsupported Method" begin
        @test_throws ErrorException compute_vdos(velocities, timestep; method="zero_padding", atom_names=atom_names)
    end
end


