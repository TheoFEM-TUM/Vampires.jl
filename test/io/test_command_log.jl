@testset "Command logging" begin
    # Test 1: Test args to command conversion
    @test Vampires.get_command_from_cli_args(["--input", "file.txt"]) == "vamp --input file.txt"

    @test Vampires.get_command_from_cli_args(["run", "--flag", "true"]) == "vamp run --flag true"

    @test Vampires.get_command_from_cli_args(["--value", "42", "-v"]) == "vamp --value 42 -v"

    @test Vampires.get_command_from_cli_args([]) == "vamp "

    @test Vampires.get_command_from_cli_args(["--path", "/some/dir/with spaces"]) == "vamp --path /some/dir/with spaces"

    mktemp() do temp_logfile, io
        command = "run_simulation"
        args = Dict("log" => "local")

        # Call the function with a temporary log file
        Vampires.write_command_to_logfile(command, args; filename=temp_logfile)

        # Read the log file contents
        log_contents = read(temp_logfile, String)

        # Check that the command is logged
        @test occursin(command, log_contents)

        # Check that the user name is in the log
        @test occursin(ENV["USER"], log_contents)

        # Check timestamp format (rough match for yyyy-mm-dd)
        @test occursin(r"\d{4}-\d{2}-\d{2}", log_contents)
    end
end