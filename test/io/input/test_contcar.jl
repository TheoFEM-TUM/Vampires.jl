
@testset "Si CONTCAR Read" begin
    contcar = read_contcar(test_file_path*"CONTCAR_si")
    @test contcar.a == 1.0
    @test contcar.atom_names == ["Si"]
    @test contcar.lattice == [2.715 0.0 2.715; 2.715 2.715 0.0; 0.0 2.715 2.715]
    @test contcar.positions == [0.0 0.25; 0.0 0.25; 0.0 0.25]
    @test contcar.atom_numbers == [2]
    @test contcar.atom_types == ["Si", "Si"]
    @test contcar.velocities == [0.0 0.0; 0.0 0.0; 0.0 0.0]
end