xdatcar = read_xdatcar(test_file_path*"XDATCAR_gaas")

@testset "XDATCAR GaAs" begin
    @test xdatcar.lattice == [5.65 0.0 0.0; 0.0 5.65 0.0; 0.0 0.0 5.65]
    @test xdatcar.positions == read_from_file(test_file_path*"configs_gaas_correct.dat")
    @test xdatcar.a == 1
    @test xdatcar.atom_numbers == [4, 4]
    @test xdatcar.atom_names == ["Ga", "As"]
    @test xdatcar.atom_types == ["Ga", "Ga", "Ga", "Ga", "As", "As", "As", "As"]
end

xdatcar_npt = read_xdatcar_npt(test_file_path*"XDATCAR_si_npt")
@testset "XDATCAR Si NPT" begin
    @test xdatcar_npt.lattice == read_from_file(test_file_path*"lattices_si_npt_correct.dat")
    @test xdatcar_npt.positions == read_from_file(test_file_path*"configs_si_npt_correct.dat")
    @test xdatcar_npt.a == 1
    @test xdatcar_npt.atom_numbers == [2]
    @test xdatcar_npt.atom_names == ["Si"]
    @test xdatcar_npt.atom_types == ["Si", "Si"]
end