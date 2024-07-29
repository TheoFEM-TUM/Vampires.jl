poscar = read_poscar(test_file_path * "POSCAR_gaas")

pc_poscar = multiply_primitive_cell(poscar, 1)
Ns = [4, 4, 4]
sc_poscar = multiply_primitive_cell(poscar, Ns)

@testset "Supercell generation" begin
    # Test identity operation
    @test pc_poscar.atom_types == poscar.atom_types
    @test pc_poscar.atom_names == poscar.atom_names
    @test pc_poscar.atom_numbers == poscar.atom_numbers
    @test pc_poscar.lattice == poscar.lattice
    @test pc_poscar.rs_atom == poscar.rs_atom

    # Test 2x2x2 supercell
    @test unique(sc_poscar.atom_types) == poscar.atom_types
    @test length(sc_poscar.atom_types) == prod(Ns) * length(poscar.atom_types)
    @test sc_poscar.atom_names == poscar.atom_names
    @test get_volume(sc_poscar.lattice) ≈ get_volume(poscar.lattice) * prod(Ns)
end