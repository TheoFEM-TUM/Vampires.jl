lmp_elem = read_lammps(test_file_path*"position_elem.lammpstrj")

@testset "LAMMPS elem" begin
    @test lmp_elem.lattice == [100.568 0.0 0.0; 0.0 100.569 0.0; 0.0 0.0 100.558]
    @test lmp_elem.positions == read_from_file(test_file_path*"configs_lammps_elem.dat")
    @test lmp_elem.a == 1
    @test lmp_elem.atom_numbers == [15, 4, 4, 5, 24]
    @test lmp_elem.atom_names == ["I", "C", "N", "Pb", "H"]
    @test lmp_elem.atom_types == ["Pb", "I", "I", "I", "H", "H", "H", "N", "C", "H", "H", "H", "Pb", "I", "I", "I", "H", "H", "H", "N", "C", "H", "H", "H", "Pb", "I", "I", "I", "H", "H", "H", "N", "C", "H", "H", "H", "Pb", "I", "I", "I", "H", "H", "H", "N", "C", "H", "H", "H", "Pb", "I", "I", "I"]
end

lmp_type = read_lammps(test_file_path*"position_type.lammpstrj")

@testset "LAMMPS type" begin
    @test lmp_type.lattice == [12.529031559003998 0.0 0.0; -0.009804375927916135 12.512643577577357 0.0; 0.009047557978906707 -0.043298123969281 12.467076643736094]
    @test lmp_type.positions == read_from_file(test_file_path*"configs_lammps_type.dat")
    @test lmp_type.a == 1
    @test lmp_type.atom_numbers == [8, 8, 24, 24, 6, 18, 8]
    @test lmp_type.atom_names == ["atom4", "atom7", "atom5", "atom6", "atom9", "atom8", "atom2"]
    @test lmp_type.atom_types == ["atom9", "atom9", "atom9", "atom9", "atom9", "atom9", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom8", "atom7", "atom7", "atom7", "atom7", "atom7", "atom7", "atom7", "atom7", "atom2", "atom2", "atom2", "atom2", "atom2", "atom2", "atom2", "atom2", "atom4", "atom4", "atom4", "atom4", "atom4", "atom4", "atom4", "atom4", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom6", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5", "atom5"]
end
