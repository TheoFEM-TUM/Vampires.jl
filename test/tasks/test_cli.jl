import Vampires: parse_commandline

@testset "CLI tests" begin
    # Test 1: Positional arguments only
    args1 = parse_commandline(["incar", "make"])
    @test args1["task"] == "incar" && args1["subtask"] == "make"

    # Test 2: Boolean flag argument
    args2 = parse_commandline(["build", "-v"])
    @test args2["task"] == "build" && args2["v"] == true

    # Test 3: Multiple keyword arguments
    args3 = parse_commandline(["--par", "ENCUT", "--val", "300"])
    @test args3["par"] == "ENCUT" && args3["val"] == "300"

    # Test 4: Combination 1
    args4 = parse_commandline(["-r", "outcar", "read", "--outcar", "OUTCAR_4"])
    @test args4["r"] && args4["task"] == "outcar" && args4["subtask"] == "read" && args4["outcar"] == "OUTCAR_4"

    # Test 5: Combination 2
    args5 = parse_commandline(["outcar", "read", "-r", "--outcar", "OUTCAR_4"])
    @test args5["r"] && args5["task"] == "outcar" && args5["subtask"] == "read" && args5["outcar"] == "OUTCAR_4"

    # Test 6: Combination 3
    args6 = parse_commandline(["--outcar", "OUTCAR_4", "-r", "outcar", "read"])
    @test args6["r"] && args6["task"] == "outcar" && args6["subtask"] == "read" && args6["outcar"] == "OUTCAR_4"

    # Test 7: Test concatenation if separated by ", "
    args7 = parse_commandline(["--par", "ENCUT,", "ISMEAR,", "LREAL"])
    @test args7["par"] == "ENCUT,ISMEAR,LREAL"

    # Test 8: Test a "--" argument without a value
    args8 = parse_commandline(["--help", "--val", "bandgap"])
    @test args8["help"] && args8["val"] == "bandgap"

    # Test 9: Test "--" argument at the end
    args9 = parse_commandline(["eigenval", "read", "--help"])
    @test args9["help"] && args9["task"] == "eigenval" && args9["subtask"] == "read"

    # Test 10: Test keyword argument with comma but no following argument
    args10 = parse_commandline(["--val", "ENCUT,"])
    @test args10["val"] == "ENCUT,"

    # Test 11: Test help flag in front of positional arguments
    args11 = parse_commandline(["--help", "incar", "set"])
    @test args11["help"] && args11["task"] == "incar" && args11["subtask"] == "set"

    # Test 12: Test h flag instead of help
    args12 = parse_commandline(["-h", "--par", "bandgap"])
    @test args12["help"] && args12["par"] == "bandgap"

    # Test 13: Test number of default args and descriptions
    default_args = Vampires.get_default_args()
    arg_descriptions = Vampires.get_arg_description()
    args_have_description = map(collect(keys(default_args))) do key
        hasdescription = haskey(arg_descriptions["posargs"], key) || haskey(arg_descriptions["optargs"], key)
        if !hasdescription
            @warn "No description found for $key, did you just add this?"
        end
        return hasdescription
    end
    @test all(args_have_description)

    # Test 14: Test that a value with '-' in it is parsed correctly
    args14 = parse_commandline(["--par", "Silicon-bandgap"])
    @test args14["par"] == "Silicon-bandgap"
end