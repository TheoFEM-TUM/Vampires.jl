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
