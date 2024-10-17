"""
list of available tasks:


"""

function run_task(::Type{Val{:eigenval}}, ::Type{Val{:plot}}, args)
    output_filename = args["o"]
    input_filename = args["p"] * args["eigenval"]
    kp, Es, _ = read_eigenval(input_filename)
    plot_bandstructure(Es, kp, output_filename)
end

function run_task(::Type{Val{:eigenval}}, ::Type{Val{:read}}, args)
    input_filename = args["p"] * args["eigenval"]
    output_filename = args["o"] == "none" ? "eigenval.h5" : args["o"]
    if occursin("h5", output_filename)
        write_eigenval_to_hdf5(input_filename, output_filename)
    else
        throw("Unknown output file format.")
    end
end