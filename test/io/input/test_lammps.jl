lmp_elem = read_lammps(test_file_path*"position_elem.lammpstrj")

@testset "LAMMPS elem" begin
    @test lmp_elem.lattice == [100.568 0.0 0.0; 0.0 100.569 0.0; 0.0 0.0 100.558]
    @test lmp_elem.positions == read_from_file(test_file_path*"configs_lammps_elem.dat")
    @test lmp_elem.a == 1
    @test lmp_elem.atom_numbers == [5, 15, 24, 4, 4]
    @test lmp_elem.atom_names == ["Pb", "I", "H", "N", "C"]
    @test lmp_elem.atom_types == [split_line(repeat("Pb ", 5)); split_line(repeat("I ", 15));  split_line(repeat("H ", 24)); split_line(repeat("N ", 4)); split_line(repeat("C ", 4))]
end

lmp_type = read_lammps(test_file_path*"position_type.lammpstrj")

@testset "LAMMPS type" begin
    @test lmp_type.lattice == [12.529031559003998 0.0 0.0; -0.009804375927916135 12.512643577577357 0.0; 0.009047557978906707 -0.043298123969281 12.467076643736094]
    @test lmp_type.positions == read_from_file(test_file_path*"configs_lammps_type.dat")
    @test lmp_type.a == 1
    @test lmp_type.atom_numbers == [6, 18, 8, 8, 8, 24, 24]
    @test lmp_type.atom_names == ["atom9", "atom8", "atom7", "atom2", "atom4", "atom6", "atom5"]
    @test lmp_type.atom_types == [split_line(repeat("atom9 ", 6)); split_line(repeat("atom8 ", 18)); split_line(repeat("atom7 ", 8)); split_line(repeat("atom2 ", 8)); split_line(repeat("atom4 ", 8)); split_line(repeat("atom6 ", 24)); split_line(repeat("atom5 ", 24))]
end

lmp_type_npt = read_lammps(test_file_path*"position_type.lammpstrj", true)

@testset "LAMMPS type npt" begin
    @test lmp_type_npt.lattice == read_from_file(test_file_path*"configs_lammps_type_npt.dat")
    @test lmp_type_npt.positions == read_from_file(test_file_path*"configs_lammps_type.dat")
    @test lmp_type_npt.a == 1
    @test lmp_type_npt.atom_numbers == [6, 18, 8, 8, 8, 24, 24]
    @test lmp_type_npt.atom_names == ["atom9", "atom8", "atom7", "atom2", "atom4", "atom6", "atom5"]
    @test lmp_type_npt.atom_types == [split_line(repeat("atom9 ", 6)); split_line(repeat("atom8 ", 18)); split_line(repeat("atom7 ", 8)); split_line(repeat("atom2 ", 8)); split_line(repeat("atom4 ", 8)); split_line(repeat("atom6 ", 24)); split_line(repeat("atom5 ", 24))]
end

lmp_first = read_lammps_first_snapshot(test_file_path*"position_type.lammpstrj")

@testset "LAMMPS first snapshot" begin
    @test lmp_first.lattice == [12.529031559003998 0.0 0.0; -0.009804375927916135 12.512643577577357 0.0; 0.009047557978906707 -0.043298123969281 12.467076643736094]
    @test lmp_first.positions == read_from_file(test_file_path*"configs_lammps_first.dat")[:, :, 1]
    @test lmp_first.a == 1
    @test lmp_first.atom_numbers == [6, 18, 8, 8, 8, 24, 24]
    @test lmp_first.atom_names == ["atom9", "atom8", "atom7", "atom2", "atom4", "atom6", "atom5"]
    @test lmp_first.atom_types == [split_line(repeat("atom9 ", 6)); split_line(repeat("atom8 ", 18)); split_line(repeat("atom7 ", 8)); split_line(repeat("atom2 ", 8)); split_line(repeat("atom4 ", 8)); split_line(repeat("atom6 ", 24)); split_line(repeat("atom5 ", 24))]
end