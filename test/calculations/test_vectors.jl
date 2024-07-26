@testset "transform_basis" begin
    Ê = [1 0 0; 0 1 0; 0 0 1]  # Identity matrix
    r⃗ = [1, 2, 3]
    @test Vampires.transform_basis(r⃗, Ê) == r⃗

    Ê = [2 0 0; 0 2 0; 0 0 2]  # Scaling matrix
    @test Vampires.transform_basis(r⃗, Ê) == 2 .* r⃗

    Ê = [0 1 0; 1 0 0; 0 0 1]  # Permutation matrix
    @test Vampires.transform_basis(r⃗, Ê) == [2, 1, 3]
end

@testset "fractional" begin
    lattice = [2 0 0; 0 2 0; 0 0 2]  # Simple cubic lattice with scaling
    r⃗_frac = [0.5, 0.5, 0.5]
    r⃗_cart = [1, 1, 1]

    @test frac_to_cart(r⃗_frac, lattice) == r⃗_cart
    @test cart_to_frac(r⃗_cart, lattice) ≈ r⃗_frac

    lattice = [1 1 0; 1 0 1; 0 1 1]  # Arbitrary lattice
    r⃗_frac = [1, 0, 0]
    r⃗_cart = [1, 1, 0]

    @test frac_to_cart(r⃗_frac, lattice) == r⃗_cart
    @test cart_to_frac(r⃗_cart, lattice) ≈ r⃗_frac

    lattice = [2.825 0.0 2.825; 2.825 2.825 0.0; 0.0 2.825 2.825]
    R = [1, -1, 2]
    @test frac_to_cart(R, lattice) == @. R[1]*lattice[:, 1] + R[2]*lattice[:, 2] + R[3]*lattice[:, 3]
end

@testset "volume" begin
    a = [1 0 0; 0 1 0; 0 0 1]  # Unit cube
    @test get_volume(a) == 1.0

    a = [2 0 0; 0 2 0; 0 0 2]  # Scaled cube
    @test get_volume(a) == 8.0

    a = [1 1 0; 0 1 1; 1 0 1]  # Parallelepiped
    @test get_volume(a) == 2.0
end

@testset "get_bs" begin
    a = [1 0 0; 0 1 0; 0 0 1]  # Unit cube
    expected_b = 2π * [1 0 0; 0 1 0; 0 0 1]
    @test get_bs(a) ≈ expected_b

    a = [2 0 0; 0 2 0; 0 0 2]  # Scaled cube
    expected_b = π * [1 0 0; 0 1 0; 0 0 1]
    @test get_bs(a) ≈ expected_b

    a = [1 1 0; 0 1 1; 1 0 1]  # Parallelepiped
    V = get_volume(a)
    expected_b = zeros(3, 3)
    expected_b[:, 1] = 2π / V .* cross(a[:, 2], a[:, 3])
    expected_b[:, 2] = 2π / V .* cross(a[:, 3], a[:, 1])
    expected_b[:, 3] = 2π / V .* cross(a[:, 1], a[:, 2])
    @test get_bs(a) ≈ expected_b
end