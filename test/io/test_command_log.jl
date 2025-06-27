@testset "Command logging" begin
    # Test 1: Test args to command conversion
    @test get_command_from_cli_args(["--input", "file.txt"]) == "vamp --input file.txt"

    @test get_command_from_cli_args(["run", "--flag", "true"]) == "vamp run --flag true"

    @test get_command_from_cli_args(["--value", "42", "-v"]) == "vamp --value 42 -v"

    @test get_command_from_cli_args([]) == "vamp "

    @test get_command_from_cli_args(["--path", "/some/dir/with spaces"]) == "vamp --path /some/dir/with spaces"
end