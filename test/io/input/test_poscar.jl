poscar = read_poscar(test_file_path*"POSCAR_gaas")

@testset "GaAs POSCAR Read" begin
    @test poscar.a == 1.0
    @test poscar.atom_names == ["Ga", "As"]
    @test poscar.lattice == [2.825 0.0 2.825; 2.825 2.825 0.0; 0.0 2.825 2.825]
    @test poscar.positions == [0.0 0.25; 0.0 0.25; 0.0 0.25]
    @test poscar.atom_numbers == [1, 1]
    @test poscar.atom_types == ["Ga", "As"]
end

write_poscar(poscar)
poscar2 = read_poscar("POSCAR")
@testset "GaAs POSCAR Write" begin
    @test poscar2.a == 1.00
    @test poscar2.atom_names == ["Ga", "As"]
    @test poscar2.lattice == [2.825 0.0 2.825; 2.825 2.825 0.0; 0.0 2.825 2.825]
    @test poscar2.positions == [0.0 0.25; 0.0 0.25; 0.0 0.25]
    @test poscar2.atom_numbers == [1, 1]
    @test poscar2.atom_types == ["Ga", "As"]
end

poscar = read_poscar(test_file_path*"POSCAR_gaas_cartesian")

@testset "GaAs POSCAR Read Cartesian" begin
    @test poscar.a == 1.0
    @test poscar.atom_names == ["Ga", "As"]
    @test poscar.lattice == [2.825 0.0 2.825; 2.825 2.825 0.0; 0.0 2.825 2.825]
    @test poscar.positions == [0.0 0.25; 0.0 0.25; 0.0 0.25]
    @test poscar.atom_numbers == [1, 1]
    @test poscar.atom_types == ["Ga", "As"]
end

@testset "add_atom_counts" begin
    atom_types_1 = ["Ga", "As"]
    atom_types_1 = Vampires.add_atom_counts(atom_types_1)
    @test atom_types_1 == ["Ga-1", "As-1"]

    atom_types_2 = ["Cs", "Pb", "Br", "Br", "Br"]
    atom_types_2 = Vampires.add_atom_counts(atom_types_2)
    @test atom_types_2 == ["Cs-1", "Pb-1", "Br-1", "Br-2", "Br-3"]
end

rm("POSCAR")