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
function read_lammps(lammps_filename, npt=false)

    lines = split_lines(open_and_read(lammps_filename))

    # Scaling parameter
    a = 1

    # number of atoms
    Nion = parse(Int64, lines[4][1])

    # extract lattice vectors
    lattice = extract_lattice_lmp(lines[5:8])

    # Find starting line of configurations
    i_start = 9

    # Calculate the number of configurations
    L = length(lines)
    Nconfig = Int(L / (Nion + i_start))

    table_line = lines[9]

    # Determine which coordinates are used: direct (xs) or cartesian (x) and find its column
    frac_coordinates = true
    index_pos = findfirst(x -> x == "xs", table_line)
    if isnothing(index_pos)
        frac_coordinates = false
        index_pos = findfirst(x -> x == "x", table_line)
    else
        throw("This LAMMPS output file does not contain atomic positions.")
    end
    index_pos -= 2

    # find column for atom_types
    elem = true
    index_elem = findfirst(x -> x == "element", table_line)
    type = false
    index_type = 0
    if isnothing(index_elem)
        elem = false
        index_elem = 0
        type = true
        index_type = findfirst(x -> x == "type", table_line)
        if isnothing(index_type)
            type = false
            index_type = 0
        else
            index_type -= 2
        end
    else
        index_elem -= 2
    end

    # Initialize
    positions = zeros(Float64, 3, Nion, Nconfig)
    atom_types = String[]
    lattices = Float64[]

    ### read all lammps data
    N = i_start + Nion
    if (npt == false)
        lattices = lattice
        for j in 1:Nconfig, i in 1:N
            if (i > i_start)
                line = lines[(j - 1) * N + i]
                if j == 1
                    if elem == true
                        push!(atom_types, line[index_elem])
                    elseif type == true
                        push!(atom_types, "atom$(parse.(Int64, line[index_type]))")
                    else
                        push!(atom_types, "unknown")
                    end
                end
                positions[:, i - i_start, j] = parse.(Float64, line[index_pos : index_pos + 2])
            end
        end
    else
        lattices = zeros(Float64, 3, 3, Nconfig)
        for j in 1:Nconfig, i in 1:N
            if (i == 5)
                if j == 1
                    lattices[:,:,j] = lattice
                else
                    lattices[:,:,j] = extract_lattice_lmp(lines[(j - 1) * N + i: (j - 1) * N + i + 3])
                end
            elseif (i > i_start)
                line = lines[(j - 1) * N + i]
                if j == 1
                    if elem == true
                        push!(atom_types, line[index_elem])
                    elseif type == true
                        push!(atom_types, "atom$(parse.(Int64, line[index_type]))")
                    else
                        push!(atom_types, "unknown")
                    end
                end
                positions[:, i - i_start, j] = parse.(Float64, line[index_pos : index_pos + 2])
            end
        end
    end

    # extract atom_names and atom_numbers from atom_types array
    atom_dict = countmap(atom_types)
    atom_numbers = collect(values(atom_dict))
    atom_names = collect(keys(atom_dict))

    # transform to fractional coordinates if needed
    if frac_coordinates == false
        positions = cart_to_frac(positions, lattice)
    end

    # Adjust positions for periodic boundary conditions
    adjust_pos_PBC!(positions)

    return Structure(a, lattices, atom_names, atom_numbers, positions, atom_types)
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

