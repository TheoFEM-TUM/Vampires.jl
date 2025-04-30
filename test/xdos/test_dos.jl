@testset "DOS Computation" begin
    # Define parameters
    sigma = 0.1
    E_grid = range(-10, stop=10, length=500)

    # Read eigenvalues from file
    kp, Es, occs = read_eigenval(test_file_path*"EIGENVAL_gaas")

    # Compute DOS and Fermi level
    dos, efermi = compute_dos(Es, occs, sigma, E_grid)
    dos_ref = read_from_file(test_file_path*"dos_gaas_correct.dat")
    @test dos == dos_ref
end
