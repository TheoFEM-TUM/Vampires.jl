function run_task(::Type{Val{:calculate}}, ::Type{Val{:bandgap}}, args)
    get_bandgap(args["p"]*args["eigenval"])    
end