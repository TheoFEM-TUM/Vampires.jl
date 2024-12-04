using Vampires



structure = read_lammps("test/test_files/position_type.lammpstrj")
println(structure.positions)
write_to_file(structure.positions, "test/test_files/configs_lammps_type")