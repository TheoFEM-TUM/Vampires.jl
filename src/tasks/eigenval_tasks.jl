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
    output_filename = args["o"]
    input_filename = args["p"] * args["eigenval"]
    kp, Es, _ = read_eigenval(input_filename)
end