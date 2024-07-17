function run_plot_task(input_filename, keyword, output_filename)
    # TODO: make this a dictionary
    println(keyword)
    if keyword == "bandstructure"
        kp, Es, occs = read_eigenval(input_filename)
        println(size(kp))
        println(size(Es))
        plot_bandstructure(Es, kp, output_filename)    
    end
    if keyword == "dos"
        dos, meta = read_doscar(input_filename)
        println(meta)
        plot_dos(dos, output_filename)    
    end
end