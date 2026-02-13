"""
    read_lammps(lammps_filename::AbstractString)

Read the configurations in dump LAMMPS output file called 'lammps_filename' and return the lattice vectors and configurations.

# Arguments
- `lammps_filename::AbstractString`: The path to the LAMMPS file.

# Returns
- `Structure`: A `Structure` struct containing all the extracted data from the LAMMPS file, including:
    - `a`: The scaling factor.
    - `lattice`: The 3x3 array of lattice vectors.
    - `atom_names`: An array of atom names.
    - `atom_numbers`: An array of the number of each type of atom.
    - `positions::Array{Float64, 3}`: 3xNionxNconfig, with Nconfig configurations represented by 3xNion coordinates
    - `atom_types`: An array of atom types corresponding to each atom position.
"""

function read_lammps(lammps_filename::AbstractString, npt::Bool=false)
    # ---- First pass: read header metadata ----
    open(lammps_filename) do io
        # Skip lines until lattice info
        readline(io)  # line 1
        readline(io)  # line 2
        readline(io)  # line 3
        Nion = parse(Int, split_line(readline(io))[1])  # line 4: number of atoms

        lattice = extract_lattice_lmp(split_lines([readline(io) for _ in 1:4]))  # lines 5-7
        i_start = 9  # header line for atom columns
        header_line = split_line(readline(io))

        # Determine position columns
        pos_idx = findfirst(==("xs"), header_line)
        frac_coordinates = true
        if pos_idx === nothing
            pos_idx = findfirst(==("x"), header_line)
            frac_coordinates = false
        end
        pos_idx -= 2  # adjust to 0-based for array indexing

        # Determine atom type column
        elem_idx = findfirst(==("element"), header_line)
        type_idx = nothing
        use_elem = true
        if elem_idx === nothing
            use_elem = false
            type_idx = findfirst(==("type"), header_line)
            type_idx = isnothing(type_idx) ? nothing : type_idx - 2
        else
            elem_idx -= 2
        end

        # ---- Count number of configurations ----
        # Efficient estimate: total lines / (Nion + i_start)
        total_lines = countlines(lammps_filename)
        N = Nion + i_start
        Nconfig = div(total_lines, N)

        # ---- Preallocate arrays ----
        positions = zeros(Float64, 3, Nion, Nconfig)
        velocities = [spzeros(Float64, 3, Nion) for _ in 1:Nconfig]
        atom_types = Vector{String}(undef, Nion)
        lattices = npt ? zeros(Float64, 3, 3, Nconfig) : lattice

        seekstart(io)

        # ---- Parse frames ----
        for j in 1:Nconfig
            # Skip header lines for this frame
            for _ in 1:4
                readline(io)
            end

            # Extract lattice if npt
            if npt
                frame_lattice_lines = split_lines([readline(io) for _ in 1:4])
                lattices[:, :, j] = j == 1 ? lattice : extract_lattice_lmp(frame_lattice_lines)
                readline(io)
            else
                for _ in 1:i_start-4
                    readline(io)
                end
            end

            # Read atom positions
            for i in 1:Nion
                line = split_line(readline(io))
                # Store atom types only once
                if j == 1
                    if use_elem
                        atom_types[i] = line[elem_idx]
                    elseif type_idx !== nothing
                        atom_types[i] = "atom$(parse(Int, line[type_idx]))"
                    else
                        atom_types[i] = "unknown"
                    end
                end
                positions[:, i, j] .= parse.(Float64, line[pos_idx:pos_idx+2])
            end
        end

        # ---- Extract atom names and counts ----
        atom_dict = countmap(atom_types)
        atom_numbers = collect(values(atom_dict))
        atom_names = collect(keys(atom_dict))
        atom_names_ordered = unique(atom_types)
        
        if atom_names != atom_names_ordered
            perm = indexin(atom_names_ordered, atom_names)
            atom_numbers = atom_numbers[perm]
            atom_names = atom_names_ordered
        end 

        # ---- Convert to fractional coordinates if needed ----
        if !frac_coordinates
            positions = cart_to_frac(positions, lattice)
        end

        # ---- Adjust PBC ----
        adjust_pos_PBC!(positions)

        # ---- Sort atoms by type ----
        order = Dict(name => i for (i, name) in enumerate(atom_names))
        sorted_idx = sortperm(1:length(atom_types), by=i -> order[atom_types[i]])
        atom_types = atom_types[sorted_idx]
        positions = positions[:, sorted_idx, :]

        return Structure(1, lattices, atom_names, atom_numbers, positions, velocities, atom_types)
    end
end


"""
    extract_lattice_lmp(lines::Array{String}, is_cubic::bool)

Extract the lattice vectors from a LAMMPS output file for cubic or non-cubic cells

# Arguments
- 'lines::Array{String}': Three lines from LAMMPS output file which only contain information for lattice vectors
- 'is_cubic::bool': true -> cell is cubic, matrix of lattice vectors is diagonal; false -> cell is non-is_cubic

# Return
- 'lattice:Array{Float64}': 3x3 matrix of the lattice vectors; each line contain one vector

"""
function extract_lattice_lmp(lines)

    # Lattice vectors
    lattice = zeros(Float64, 3, 3)

    if (lines[1][4] == "xy")  # non-cubic cell

        # Extract parameter from files
        l = parse_lines_as_array(lines[2:4])

        # Assign lattice vectors
        latt_11 = l[1,2] + max(0, l[1,3], l[2,3], l[2,3] + l[3,3]) - (l[1,1] + min(0, l[2,2], l[2,3], l[2,3] + l[3,3]))
        latt_22 = l[2,2] + max(0, l[3,3]) - (l[2,1] + min(0, l[3,3]))
        latt_33 = l[3,2] - l[3,1]
        lattice[1,1] = latt_11
        lattice[2,2] = latt_22
        lattice[3,3] = latt_33
        lattice[2,1] = l[1,3]
        lattice[3,1] = l[2,3]
        lattice[3,2] = l[3,3]

    elseif (lines[1][4] == "abc") # non-cubic cell in abc format

        l = parse_lines_as_array(lines[2:4])

        lattice = l[1:3,1:3]

    else # cubic cell

        # Assign lattice vectors
        l = parse_lines_as_array(lines[2:4], i2=2)
        latt_11 = l[1,2] - l[1,1]
        latt_22 = l[2,2] - l[2,1]
        latt_33 = l[3,2] - l[3,1]
        lattice[1,1] = latt_11
        lattice[2,2] = latt_22
        lattice[3,3] = latt_33

    end


    return lattice
end




"""
    read_lammps_first_snapshot(lammps_filename::AbstractString)

Read the first configurations in dump LAMMPS output file called 'lammps_filename' and return the structure of the first configuration.

# Arguments
- `lammps_filename::AbstractString`: The path to the LAMMPS file.

# Returns
- `Structure`: A `Structure` struct containing all the extracted data from the LAMMPS file, including:
    - `a`: The scaling factor.
    - `lattice`: The 3x3 array of lattice vectors.
    - `atom_names`: An array of atom names.
    - `atom_numbers`: An array of the number of each type of atom.
    - `positions::Array{Float64, 3}`: 3xNionxNconfig, with Nconfig configurations represented by 3xNion coordinates
    - `atom_types`: An array of atom types corresponding to each atom position.
"""

function read_lammps_first_snapshot(lammps_filename::AbstractString)

    # ---- First pass: read header metadata ----
    open(lammps_filename) do io
        # Skip lines until lattice info
        readline(io)  # line 1
        readline(io)  # line 2
        readline(io)  # line 3
        Nion = parse(Int, split_line(readline(io))[1])  # line 4: number of atoms

        lattice = extract_lattice_lmp(split_lines([readline(io) for _ in 1:4]))  # lines 5-7
        header_line = split_line(readline(io))

        # Determine position columns
        pos_idx = findfirst(==("xs"), header_line)
        frac_coordinates = true
        if pos_idx === nothing
            pos_idx = findfirst(==("x"), header_line)
            frac_coordinates = false
        end
        pos_idx -= 2  # adjust to 0-based for array indexing

        # Determine atom type column
        elem_idx = findfirst(==("element"), header_line)
        type_idx = nothing
        use_elem = true
        if elem_idx === nothing
            use_elem = false
            type_idx = findfirst(==("type"), header_line)
            type_idx = isnothing(type_idx) ? nothing : type_idx - 2
        else
            elem_idx -= 2
        end


        # ---- Preallocate arrays ----
        positions = zeros(Float64, 3, Nion)
        velocities = spzeros(Float64, 3, Nion)
        atom_types = Vector{String}(undef, Nion)

        # Read atom positions
        for i in 1:Nion
            line = split_line(readline(io))
            # Store atom types only once
            if use_elem
                atom_types[i] = line[elem_idx]
            elseif type_idx !== nothing
                atom_types[i] = "atom$(parse(Int, line[type_idx]))"
            else
                atom_types[i] = "unknown"
            end
            positions[:, i] .= parse.(Float64, line[pos_idx:pos_idx+2])
        end

        # ---- Extract atom names and counts ----
        atom_dict = countmap(atom_types)
        atom_numbers = collect(values(atom_dict))
        atom_names = collect(keys(atom_dict))
        atom_names_ordered = unique(atom_types)
        
        if atom_names != atom_names_ordered
            perm = indexin(atom_names_ordered, atom_names)
            atom_numbers = atom_numbers[perm]
            atom_names = atom_names_ordered
        end 

        # ---- Convert to fractional coordinates if needed ----
        if !frac_coordinates
            positions = cart_to_frac(positions, lattice)
        end

        # ---- Adjust PBC ----
        adjust_pos_PBC!(positions)

        # ---- Sort atoms by type ----
        order = Dict(name => i for (i, name) in enumerate(atom_names))
        sorted_idx = sortperm(1:length(atom_types), by=i -> order[atom_types[i]])
        atom_types = atom_types[sorted_idx]
        positions = positions[:, sorted_idx]

        return Structure(1, lattice, atom_names, atom_numbers, positions, velocities, atom_types)
    end
end
