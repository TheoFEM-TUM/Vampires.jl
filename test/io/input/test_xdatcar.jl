xdatcar = read_xdatcar(test_file_path*"XDATCAR_gaas")

@testset "XDATCAR GaAs" begin
    @test xdatcar.lattice == [5.65 0.0 0.0; 0.0 5.65 0.0; 0.0 0.0 5.65]
    @test xdatcar.positions == read_from_file(test_file_path*"configs_gaas_correct.dat")
    @test xdatcar.a == 1
    @test xdatcar.atom_numbers == [4, 4]
    @test xdatcar.atom_names == ["Ga", "As"]
    @test xdatcar.atom_types == ["Ga", "Ga", "Ga", "Ga", "As", "As", "As", "As"]
end