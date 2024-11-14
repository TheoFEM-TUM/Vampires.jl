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

# Create test data
positions = reshape([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9], 3, 3, 1)
lattice = [4.0 0.0 0.0; 0.0 2.0 0.0; 0.0 0.0 1.0]
atom_names = ["Si", "Ga", "B"]
atom_types = ["Si", "Ga", "Ga", "B", "B", "B", "B"]
atom_numbers = [1, 2, 4]
a = 3.4
structure = Structure(a, lattice, atom_names, atom_numbers, positions, atom_types)
structure_array = repeat([structure], 17)

@testset "XDATCAR write" begin
    @testset "write_xdatcar_body" begin
        io = IOBuffer()
        running_index = Vampires.write_xdatcar_body(io, structure, 1)
        expected_output = """
        Direct configuration=     1
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        """
        @test String(take!(io)) == expected_output
        @test running_index == 2
    end

    @testset "write_combined_xdatcar" begin
        io = IOBuffer()
        Vampires.write_combined_xdatcar(io, structure_array)

        expected_output = """
        unknown structure
                   3.4
             4.000000    0.000000    0.000000
             0.000000    2.000000    0.000000
             0.000000    0.000000    1.000000
           Si   Ga   B
             1     2     4
        Direct configuration=     1
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=     2
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=     3
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=     4
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=     5
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=     6
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=     7
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=     8
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=     9
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=    10
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=    11
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=    12
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=    13
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=    14
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=    15
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=    16
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        Direct configuration=    17
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        """
        @test String(take!(io)) == expected_output
    end
end
