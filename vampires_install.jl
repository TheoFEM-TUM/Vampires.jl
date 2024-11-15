println("********************************************************************************")
println("* Welcome to                                                                   *")
println("* __     ___    __  __ ____ ___ ____  _____                                    *")
println("* \\ \\   / / \\  |  \\/  |  _ \\_ _|  _ \\| ____|___    VASP Analysis               *")
println("*  \\ \\ / / _ \\ | |\\/| | |_) | || |_) |  _| / __|     for Materials Properties  *")
println("*   \\ V / ___ \\| |  | |  __/| ||  _ <| |___\\__ \\          In Realistic         *")
println("*    \\_/_/   \\_\\_|  |_|_|  |___|_| \\_\\_____|___/         Energy Surfaces       *")
println("*                                                                              *")
println("********************************************************************************")

using Pkg

# Add and import the `ArgParse` package
Pkg.add("ArgParse")
using ArgParse

vampires_path = string(@__DIR__)

Pkg.develop(PackageSpec(path=vampires_path))
Pkg.activate(vampires_path)
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
            default = "default"
        "--add_path"
            help = "decides whether the Vampires package is added to path"
            arg_type = String
            default = "yes"
    end
    args :: Dict{String, String} = parse_args(s)
    return args
end

#Check if Vampires can be imported
try
    cd("..")
    using Vampires
    cd(vampires_path)
catch e
    println("Vampire was not installed successfully")
    rethrow(e)
end

# Add Vampires executable to path
args = parse_commandline()
exec_name = args["exec_name"]
exec_file = joinpath(vampires_path, exec_name)
if !isfile(exec_file)
    println("Generating Vampires.jl executable...")
    open(exec_file, "w+") do file
        println(file, "#!/bin/bash")
        println(file, "julia --project=$vampires_path $vampires_path/vampires_main.jl \"\$@\"")
    end
    println("")
    run(`chmod +x $exec_file`)
end

if args["add_path"] == "yes"
    println("Adding Vampires.jl to PATH...")
    bashrc_path = args["bashrc"] == "default" ? joinpath(ENV["HOME"], ".bashrc") : args["bashrc"]
    open(bashrc_path, "a") do bashrc_file
        println(bashrc_file, "")
        println(bashrc_file, "# Add Vampires.jl to PATH.")
        println(bashrc_file, "export PATH=\"\$PATH:$vampires_path\"")
    end
    println("")
end

Pkg.test("Vampires")

println("Vampires was configured successfully.")
println("")
println("You can now use the Vampires CLI interface.")
println("Try `$exec_name --help`!")