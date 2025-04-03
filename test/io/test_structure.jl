@testset "Structure" begin
    @testset "parse_structure_file_header" begin
        structure_header = """
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
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.70000000    0.80000000    0.90000000
        """
        structure_header = split(structure_header, "\n")
        structure_header = Vampires.split_lines(structure_header)
        a, lattice, atom_names, atom_numbers, atom_types, Nion = Vampires.parse_structure_file_header(structure_header)
        @test a == 1.0
        @test lattice == [13.6 0.0 0.0; 0.0 6.8 0.0; 0.0 0.0 3.4]
        @test atom_numbers == [1, 2, 4]
        @test atom_types == ["Si", "Ga", "Ga", "B", "B", "B", "B"]
        @test Nion == 7
    end
    @testset "parse_structure_file_header wrong atom number" begin
        structure_header = """
        unknown structure
                   3.4
             4.000000    0.000000    0.000000
             0.000000    2.000000    0.000000
             0.000000    0.000000    1.000000
           Si   Ga   B
             1     2
        Direct configuration=     1
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.10000000    0.20000000    0.30000000
            0.40000000    0.50000000    0.60000000
            0.10000000    0.20000000    0.30000000
        """
        structure_header = split(structure_header, "\n")
        structure_header = Vampires.split_lines(structure_header)
        @test_throws String a, lattice, atom_names, atom_numbers, atom_types, Nion = Vampires.parse_structure_file_header(structure_header)
    end

end
