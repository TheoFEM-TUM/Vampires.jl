lattice = read_poscar(test_file_path*"POSCAR_gaas").lattice

@test convert_kspacing_to_kgrid(0.2, lattice) == [10, 10, 10]
@test convert_kspacing_to_kgrid(0.5, lattice) == [4, 4, 4]