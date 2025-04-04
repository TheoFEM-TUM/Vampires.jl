@testset "Autocorroletion via Wiener–Khinchin" begin
    v = [3, 2, -1]
    @test [14, 1, 1] == compute_autocorr(v; normalize=false)
    @test isapprox([8.666666, -4.333333, -4.333333], compute_autocorr(v; normalize=true), atol=1e-6)
end

@testset "Full Autocorroletion Function" begin
    v = [2, 3, -1]
    @test isapprox([-2, 3, 14, 3, -2], Vampires.compute_full_autocorrelation(v), atol=1e-6)
end

@testset "Spectral Function" begin
    v = [1.3901194830787669
    0.1830127018922193
   -0.024094079294328274
    0.1830127018922193]
    @test isapprox([3, 2, 1], compute_spectral_density(v; normalize=false), atol=1e-6)
    @test isapprox([0, 2, 1], compute_spectral_density(v; normalize=true), atol=1e-6)
end
