@testset "Command logging" begin
    # Test 1: Test args to command conversion
    @test Vampires.get_command_from_cli_args(["--input", "file.txt"]) == "vamp --input file.txt"

    @test Vampires.get_command_from_cli_args(["run", "--flag", "true"]) == "vamp run --flag true"

    @test Vampires.get_command_from_cli_args(["--value", "42", "-v"]) == "vamp --value 42 -v"

    @test Vampires.get_command_from_cli_args([]) == "vamp "

    @test Vampires.get_command_from_cli_args(["--path", "/some/dir/with spaces"]) == "vamp --path /some/dir/with spaces"
end