function run_task(::Type{Val{:plot}}, ::Type{Val{:bandstructure}}, args)
    output_filename = args["o"]
    input_filename = args["p"] * args["eigenval"]
    kp, Es, occs = read_eigenval(input_filename)
    plot_bandstructure(Es, kp, output_filename)    
end

function run_task(::Type{Val{:plot}}, ::Type{Val{:dos}}, args)
    input_filename = args["p"] * args["doscar"]
    dos, meta = read_doscar(input_filename)
    plot_dos(dos, args["o"])    
end