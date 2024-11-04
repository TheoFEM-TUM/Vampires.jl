println("Welcome to")
println("")
println("__     ___    __  __ ____ ___ ____  _____")
println("\\ \\   / / \\  |  \\/  |  _ \\_ _|  _ \\| ____|___")
println(" \\ \\ / / _ \\ | |\\/| | |_) | || |_) |  _| / __|")
println("  \\ V / ___ \\| |  | |  __/| ||  _ <| |___\\__ \\")
println("   \\_/_/   \\_\\_|  |_|_|  |___|_| \\_\\_____|___/")
println("")

println("Starting Vampires installation...")

using Pkg

# Add and import the `ArgParse` package
Pkg.add("ArgParse")
using ArgParse

Pkg.develop(PackageSpec(path="."))
Pkg.activate(".")
Pkg.instantiate()

# Parse command line arguments
function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--exec_name"
            help = "defines the name of the Vampires executable alias"
            arg_type = String
            default = "vamp"
        "--bashrc"
            help = "sets the path where your executable is located"
            arg_type = String
            default = "~/.bashrc"
    end
    args :: Dict{String, String} = parse_args(s)
    return args
end

#Check if Vampires can be imported
vampires_path = string(@__DIR__)
try 
    cd("..")
    using Vampires
    cd(vampires_path)
catch e
    println("Vampire was not installed successfully", e)
end

# Add Vampires executable to path
args = parse_commandline()
vampires_exec = vampires_path * "/vampires_exec.jl"
exec_name = args["exec_name"]
alias = "alias $exec_name='julia $vampires_exec'"
bashrc_path = args["bashrc"]

# Add line to bashrc file
open(bashrc_path, "a") do bashrc_file
    println(bashrc_file, "")
    println(bashrc_file, "# Create an alias for the Vampires.jl package.")
    println(bashrc_file, alias)
end

Pkg.test("Vampires")

println("Vampires was configured successfully.")
