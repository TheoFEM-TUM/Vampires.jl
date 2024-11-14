lattice = read_poscar(test_file_path*"POSCAR_gaas").lattice

@test convert_kspacing_to_kgrid(0.2, lattice) == [10, 10, 10]
@test convert_kspacing_to_kgrid(0.5, lattice) == [4, 4, 4]

@testset "find kpoint" begin
    # Test 1: Basic test to find a k-point in the list
    kpoints = [ [0.0, 0.0, 0.0] [0.5, 0.5, 0.5] [1.0, 1.0, 1.0] ]
    kpoint = [0.5, 0.5, 0.5]
    @test Vampires.find_kpoint(kpoint, kpoints) == 2

    # Test 2: Check for a k-point at the start of the list
    kpoint_start = [0.0, 0.0, 0.0]
    @test Vampires.find_kpoint(kpoint_start, kpoints) == 1

    # Test 3: Check for a k-point at the end of the list
    kpoint_end = [1.0, 1.0, 1.0]
    @test Vampires.find_kpoint(kpoint_end, kpoints) == 3

    # Test 4: Handling consecutive duplicate k-points
    kpoints_with_duplicates = [ [0.0, 0.0, 0.0] [0.5, 0.5, 0.5] [0.5, 0.5, 0.5] [1.0, 1.0, 1.0] ]
    @test Vampires.find_kpoint(kpoint, kpoints_with_duplicates) == 3  # Should return the last duplicate

    # Test 5: Handling non-existent k-point
    kpoint_nonexistent = [0.25, 0.25, 0.25]
    @test Vampires.find_kpoint(kpoint_nonexistent, kpoints) === nothing  # Should return `nothing` when not found

    # Test 6: Approximate matching due to floating-point precision
    kpoints_approx = [ [0.0, 0.0, 0.0] [0.49999999999, 0.5, 0.5] [1.0, 1.0, 1.0] ]
    kpoint_approx = [0.5, 0.5, 0.5]
    @test Vampires.find_kpoint(kpoint_approx, kpoints_approx) == 2  # Should find approximately equal k-point
end