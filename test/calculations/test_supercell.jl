poscar = read_poscar(test_file_path * "POSCAR_gaas")

pc_poscar = transform_primitive_cell(poscar, 1)
Ns = [4, 4, 4]
sc_poscar = transform_primitive_cell(poscar, Ns)

@testset "Supercell generation" begin
    # Test identity operation
    @test pc_poscar.atom_types == poscar.atom_types
    @test pc_poscar.atom_names == poscar.atom_names
    @test pc_poscar.atom_numbers == poscar.atom_numbers
    @test pc_poscar.lattice == poscar.lattice
    @test pc_poscar.positions == poscar.positions

    # Test 2x2x2 supercell
    @test unique(sc_poscar.atom_types) == poscar.atom_types
    @test length(sc_poscar.atom_types) == prod(Ns) * length(poscar.atom_types)
    @test sc_poscar.atom_names == poscar.atom_names
    @test get_volume(sc_poscar.lattice) ≈ get_volume(poscar.lattice) * prod(Ns)
end

path = test_file_path*"param_test/"
N = 10; Nmin = 5
supercell_create_subdirectories(path, test_file_path*"XDATCAR_gaas", N, method="random", Nmin=Nmin)
xdatcar = read_xdatcar(test_file_path*"XDATCAR_gaas")
@testset "Supercell snapshots" begin
    inds = read_from_file(path*"config_inds.dat", type=Int64)
    @test length(inds) == N
    for i in 1:N, file in ["POSCAR", "POTCAR", "KPOINTS", "INCAR"]
        @test file ∈ readdir(path*"config_$i")
    end
    for i in 1:N
        poscar = read_poscar(path*"config_$i/POSCAR")
        xdat_pos = xdatcar.positions[:, :, inds[i]]
        @test poscar.positions == xdat_pos
    end
    @test minimum(inds) ≥ Nmin
end
rm(path*"config_inds.dat")
for i in 1:N
    rm(path*"config_$i", recursive=true)
end