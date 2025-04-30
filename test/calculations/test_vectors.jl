@testset "transform_basis" begin
    Ê = [1 0 0; 0 1 0; 0 0 1]  # Identity matrix
    r = [1, 2, 3]
    t = [1 1 1; 2 2 2; 3 3 3;;;1 1 1; 2 2 2; 3 3 3;;;]  # Ncoord x Natoms x Ntime
    @test Vampires.transform_basis(r, Ê) == r
    @test Vampires.transform_basis(t, Ê) == t

    Ê = [2 0 0; 0 2 0; 0 0 2]  # Scaling matrix
    @test Vampires.transform_basis(r, Ê) == 2 .* r
    @test Vampires.transform_basis(t, Ê) == 2 .* t

    Ê = [0 1 0; 1 0 0; 0 0 1]  # Permutation matrix
    @test Vampires.transform_basis(r, Ê) == [2, 1, 3]
    @test Vampires.transform_basis(t, Ê) == [2 2 2; 1 1 1; 3 3 3;;;2 2 2; 1 1 1; 3 3 3;;;]
end

@testset "fractional" begin
    lattice = [2 0 0; 0 2 0; 0 0 2]  # Simple cubic lattice with scaling
    r_frac = [0.5, 0.5, 0.5]
    r_cart = [1, 1, 1]

    @test frac_to_cart(r_frac, lattice) == r_cart
    @test cart_to_frac(r_cart, lattice) ≈ r_frac

    lattice = [1 1 0; 1 0 1; 0 1 1]  # Arbitrary lattice
    r_frac = [1, 0, 0]
    r_cart = [1, 1, 0]

    @test frac_to_cart(r_frac, lattice) == r_cart
    @test cart_to_frac(r_cart, lattice) ≈ r_frac

    lattice = [2.825 0.0 2.825; 2.825 2.825 0.0; 0.0 2.825 2.825]
    R = [1, -1, 2]
    @test frac_to_cart(R, lattice) == @. R[1]*lattice[:, 1] + R[2]*lattice[:, 2] + R[3]*lattice[:, 3]
end

@testset "fractional with tensor" begin
    lattice = [2 0 0; 0 2 0; 0 0 2]  # Simple cubic lattice with scaling
    t_frac = [0.5 0.5 0.5; 1 1 1; 0.75 0.75 0.75;;;0.5 0.5 0.5; 1 1 1; 0.75 0.75 0.75;;;]
    t_cart = [1 1 1; 2 2 2; 1.5 1.5 1.5;;;1 1 1; 2 2 2; 1.5 1.5 1.5;;;]

    @test frac_to_cart(t_frac, lattice) == t_cart
    @test cart_to_frac(t_cart, lattice) ≈ t_frac

    lattice = [1 1 0; 1 0 1; 0 1 1]  # Arbitrary lattice
    r_frac = [1 1 1; 0 0 0; 0 0 0;;;1 1 1; 0 0 0; 0 0 0;;;]
    r_cart = [1 1 1; 1 1 1; 0 0 0;;;1 1 1; 1 1 1; 0 0 0;;;]

    @test frac_to_cart(r_frac, lattice) == r_cart
    @test cart_to_frac(r_cart, lattice) ≈ r_frac

    lattice = [2.825 0.0 2.825; 2.825 2.825 0.0; 0.0 2.825 2.825]
    R = [1 1 1; -1 -1 -1; 2 2 2;;;1 1 1; -1 -1 -1; 2 2 2;;;1 1 1; -1 -1 -1; 2 2 2;;;1 1 1; -1 -1 -1; 2 2 2;;;]
    @test isapprox(frac_to_cart(R, lattice), [8.475 8.475 8.475; 0.0 0.0 0.0; 2.825 2.825 2.825;;; 8.475 8.475 8.475; 0.0 0.0 0.0; 2.825 2.825 2.825;;; 8.475 8.475 8.475; 0.0 0.0 0.0; 2.825 2.825 2.825;;; 8.475 8.475 8.475; 0.0 0.0 0.0; 2.825 2.825 2.825])
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

@testset "get_lattice_parameter" begin
    # Unit cube
    lattice = [1.0 0 0; 0 1.0 0; 0 0 1.0]
    str = Structure(1.0, lattice, ["X"], [1], zeros(3,1), zeros(3, 1), ["X"])
    a, b, c, α, β, γ, volume = get_lattice_parameter(str)
    @test a ≈ 1.0
    @test b ≈ 1.0
    @test c ≈ 1.0
    @test α ≈ 90.0
    @test β ≈ 90.0
    @test γ ≈ 90.0
    @test volume ≈ 1.0

    # Scaled cube
    lattice = [2.0 0 0; 0 2.0 0; 0 0 2.0]
    str = Structure(1.0, lattice, ["X"], [1], zeros(3,1), zeros(3,1), ["X"])
    a, b, c, α, β, γ, volume = get_lattice_parameter(str)

    @test a ≈ 2.0
    @test b ≈ 2.0
    @test c ≈ 2.0
    @test α ≈ 90.0
    @test β ≈ 90.0
    @test γ ≈ 90.0
    @test volume ≈ 8.0

    # Parallelepiped with known angles
    lattice = [1.0 1.0 0.0; 0.0 1.0 1.0; 1.0 0.0 1.0]
    str = Structure(1.0, lattice, ["X"], [1], zeros(3,1), zeros(3,1), ["X"])
    a, b, c, α, β, γ, volume = get_lattice_parameter(str)

    @test isapprox(a, norm(lattice[:,1]), atol=1e-8)
    @test isapprox(b, norm(lattice[:,2]), atol=1e-8)
    @test isapprox(c, norm(lattice[:,3]), atol=1e-8)
    @test isapprox(α, acosd(dot(lattice[:,2], lattice[:,3]) / (b * c)), atol=1e-8)
    @test isapprox(β, acosd(dot(lattice[:,1], lattice[:,3]) / (a * c)), atol=1e-8)
    @test isapprox(γ, acosd(dot(lattice[:,1], lattice[:,2]) / (a * b)), atol=1e-8)
    @test isapprox(volume, get_volume(lattice), atol=1e-8)
end

