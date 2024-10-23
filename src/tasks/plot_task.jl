"""
list of available tasks:

plot
    bandstructure: plots the bandstructure
    dos: plots the density of states
"""


#TODO: Unify this with file methods, i.e., vamp eigenval plot
function run_task(::Type{Val{:bands}}, ::Type{Val{:plot}}, args)
    output_filename = args["o"]
    input_filename = args["p"] * args["eigenval"]
    kp, Es, _ = read_eigenval(input_filename)
    plot_bandstructure(Es, kp, output_filename)    
end

function run_task(::Type{Val{:dos}}, ::Type{Val{:plot}}, args)
    input_filename = args["p"] * args["doscar"]
    dos, _ = read_doscar(input_filename)
    plot_dos(dos, args["o"])    
end