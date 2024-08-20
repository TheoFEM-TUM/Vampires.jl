using HDF5

function get_atoms_configuration(poscar)
    try
        @debug "Reading $poscar"
        poscarfile = open(poscar, "r")
        lines = readlines(poscarfile)
        close(poscarfile)

        potcar_info = split(lines[6])
        atoms_conf = []

        @debug "Atom configuration:"
        for atom in potcar_info
            atom_conf = split(atom, '/')
            if length(atom_conf) == 1
                push!(atom_conf, "latest")
            end
            push!(atoms_conf, atom_conf)
            @debug "    $(atom_conf[1]): $(atom_conf[2])"
        end

    catch e
        @error "Error reading $poscar: $(e)"
    end

    return atoms_conf
end

function get_potcar_from_h5(potcarh5, atoms_conf, pottype)
    potcar_info = []
    if haskey(potcarh5, pottype)
        for atom_conf in atoms_conf
            if haskey(potcarh5[pottype], atom_conf[1])
                atom_rev = keys(potcarh5[pottype][atom_conf[1]])
                for i in atom_rev
                    if startswith(String(i), atom_conf[2])
                        @info "$pottype/$(atom_conf[1])/$(atom_conf[2]) found"
                        push!(potcar_info, read(potcarh5[pottype][atom_conf[1]][i], String))
                    end
                end
            else
                @error "$(atom_conf[1]) not found in h5"
            end
        end
    else
        @error "$pottype not found in h5 file"
    end
    return potcar_info
end

function run_task(::Type{Val{:potcar}}, ::Type{Val{:make}}, args)
    if args.v
        global_logger(ConsoleLogger(stderr, Logging.Debug))
        @info "Verbose output!"
    else
        global_logger(ConsoleLogger(stderr, Logging.Info))
    end

    if ismissing(args.poscar)
        if isfile("POSCAR")
            args.poscar = "POSCAR"
        else
            error("POSCAR not found")
        end
    end

    if ismissing(args.inp)
        if !isempty(ENV["VASP_POTENTIALS"])
            args.inp = ENV["VASP_POTENTIALS"]
        else
            error("POTCAR.h5 not found")
        end
    end

    @info "Using $(args.inp) for lookup"

    potcarh5 = h5open(args.inp, "r")
    atoms_conf = get_atoms_configuration(args.poscar)
    potcar_info = get_potcar_from_h5(potcarh5, atoms_conf, args.method)

    potcar_filename = args.o == "none" ? "POTCAR" : args.o
    open(potcar_filename, "w") do potcar_file
        write(potcar_file, join(potcar_info, ""))
    end

    close(potcarh5)
end