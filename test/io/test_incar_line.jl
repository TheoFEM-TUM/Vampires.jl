
read_incar_line = Vampires.read_incar_line
@testset "INCAR line" begin
    # Test case 1: Line with key, value, and comment
    line1 = "ENCUT = 520 ! Plane wave cutoff"
    result1 = read_incar_line(line1)
    @test result1 == ["ENCUT", "520", "Plane wave cutoff"]

    # Test case 2: Line with key and value only and no spacing
    line2 = "ISMEAR=0"
    result2 = read_incar_line(line2)
    @test result2 == ["ISMEAR", "0", ""]

    # Test case 3: Line with key, value, and different comment character
    line3 = "EDIFF = 1e-4 # Convergence criterion"
    result3 = read_incar_line(line3)
    @test result3 == ["EDIFF", "1e-4", "Convergence criterion"]

    # Test case 4: Line with key, value, and custom splitting characters
    line4 = "LREAL = .FALSE. : Real space projection"
    result4 = read_incar_line(line4, ['=', ':'])
    @test result4 == ["LREAL", ".FALSE.", "Real space projection"]

    # Test case 5: Line with leading and trailing spaces
    line5 = "   ALGO = Fast   ! Algorithm choice    "
    result5 = read_incar_line(line5)
    @test result5 == ["ALGO", "Fast", "Algorithm choice"]

    # Test case 6: Line with only key and no value
    line6 = "NCORE ="
    @test_throws ArgumentError read_incar_line(line6)

    # Test case 7: Empty line
    line7 = ""
    @test_throws ArgumentError read_incar_line(line7)
end

@testset "INCAR block_label" begin
    @test Vampires.isblock_label("!MyLabel") == true
    @test Vampires.get_block_label("!MyLabel") == "MyLabel"

    @test Vampires.isblock_label("! MyLabel") == true
    @test Vampires.get_block_label("! MyLabel") == "MyLabel"

    @test Vampires.isblock_label("#MyLabel") == true
    @test Vampires.get_block_label("#MyLabel") == "MyLabel"

    @test Vampires.isblock_label("# MyLabel") == true
    @test Vampires.get_block_label("# MyLabel") == "MyLabel"

    @test Vampires.isblock_label("#ISMEAR=1") == false
end

@testset "Wannier90 keys" begin
    for key in ["num_wann", "projAs", "write_hr"]
        @test Vampires.iswannier90key(key)
    end
    for key in ["ENCUT", "ML_MODE", "LWANNIER90"]
        @test Vampires.iswannier90key(key) == false
    end
end