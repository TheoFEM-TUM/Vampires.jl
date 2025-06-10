using Vampires

test_file_path = "test/test_files/"

lmp_elem = Vampires.read_lammps(test_file_path*"position_type.lammpstrj")

Vampires.write_to_file(lmp_elem.positions, test_file_path*"configs_lammps_type")

