function run_plot_task(args)
    keyword = args["subtask"]
    output_filename = args["o"]
    # TODO: make this a dictionary
    println(keyword)
    if keyword == "bandstructure"
        input_filename = args["p"] * args["eigenval"]
        kp, Es, occs = read_eigenval(input_filename)
        println(size(kp))
        println(size(Es))
        plot_bandstructure(Es, kp, output_filename)    
    end
    if keyword == "dos"
        input_filename = args["p"] * args["doscar"]
        dos, meta = read_doscar(input_filename)
        println(meta)
        plot_dos(dos, output_filename)    
    end
end