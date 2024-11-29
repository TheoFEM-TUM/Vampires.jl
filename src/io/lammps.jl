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
function read_lammps(lammps_filename)

    lines = split_lines(open_and_read(lammps_filename))

    # Scaling parameter
    a = 1

    # number of atoms
    Nion = parse(Int64, lines[4][1])
    
    # extract lattice vectors
    is_cubic = (lines[5][4] == "pp")
    if (!is_cubic) && (lines[5][4] != "xy")
        throw("Unusual LAMMPS output file, please check it!")
    end
    lattice = extract_lattice_lmp(lines[6:8], is_cubic)

    # Find starting line of configurations
    i_start = 9

    # Calculate the number of configurations
    L = length(lines)
    Nconfig = Int(L / (Nion + i_start))

    # Determine which coordinates are used: direct (xs) or cartesian (x) and find its column
    direct_coordinates = true
    index_pos = findfirst(x -> x == "xs", lines[9])
    if isnothing(index_pos)
        direct_coordinates = false
        index_pos = findfirst(x -> x == "x", lines[9]) 
    else
        throw("This LAMMPS output file does not contain atomic positions.")
    end
    index_pos -= 2

    # find column for atom_types
    elem = true
    index_elem = findfirst(x -> x == "element", lines[9])
    type = false
    index_type = 0
    if isnothing(index_elem)
        elem = false
        index_elem = 0
        type = true
        index_type = findfirst(x -> x == "type", lines[9])
        if isnothing(index_type)
            type = false
            index_type = 0      
        else
            index_type -= 2
        end
    else
        index_elem -= 2
    end

    # extract atom_types
    atom_types = String[]
    if elem == true
        for i in 1:Nion
            k = i_start + i
            elem_name = lines[k][index_elem]
            push!(atom_types, elem_name)
        end
    elseif type == true
        for i in 1:Nion
            k = i_start + i
            type_name = parse.(Int64, lines[k][index_type])
            push!(atom_types, "atom$(type_name)")
        end
    else
        for _ in 1:Nion
            push!(atom_types, "unknown")
        end
    end
    ### please check if atom1 or unknown as atom_types cause problems

    # extract atom_names and atom_numbers from atom_types array 
    atom_dict = countmap(atom_types)
    atom_numbers = collect(values(atom_dict))
    atom_names = collect(keys(atom_dict))

    # Initialize the configurations array
    positions = zeros(Float64, 3, Nion, Nconfig)

    # read out positions
    for j in 1:Nconfig, i in 1:Nion
        k = (j - 1) * (i_start + Nion) + i_start + i 
        positions[:, i, j] = parse.(Float64, lines[k][index_pos : index_pos + 2])
    end

    # transform to direct_coordinates
    if direct_coordinates == false
        inv_lattice = inv(lattice')
        for j in 1:Nconfig, i in 1:Nion
            positions[:,i,j] = inv_lattice * positions[:,i,j]
        end
    end

    # Adjust positions for periodic boundary conditions
    adjust_periodic_boundary_lmp!(positions)

    return Structure(a, lattice, atom_names, atom_numbers, positions, atom_types)
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
function extract_lattice_lmp(lines, is_cubic)

    # Lattice vectors
    lattice = zeros(Float64, 3, 3)
    
    latt_33 = parse(Float64, lines[3][2]) - parse(Float64, lines[3][1])

    if is_cubic # cubic cell
    
        # Assign lattice vectors
        latt_11 = parse(Float64, lines[1][2]) - parse(Float64, lines[1][1])
        latt_22 = parse(Float64, lines[2][2]) - parse(Float64, lines[2][1])
        lattice[1,1] = latt_11
        lattice[2,2] = latt_22
        lattice[3,3] = latt_33

    else # non-cubic cell

        # Extract parameter from files
        l11 = parse(Float64, lines[1][1])
        l12 = parse(Float64, lines[1][2])
        l13 = parse(Float64, lines[1][3])
        l21 = parse(Float64, lines[2][1])
        l22 = parse(Float64, lines[2][2])
        l23 = parse(Float64, lines[2][3])
        l33 = parse(Float64, lines[3][3])
        
        # Assign lattice vectors
        latt_11 = l12 + max(0, l13, l23, l23 + l33) - (l11 + min(0, l22, l23, l23 + l33))
        latt_22 = l22 + max(0, l33) - (l21 + min(0, l33))
        lattice[1,1] = latt_11
        lattice[2,2] = latt_22
        lattice[3,3] = latt_33
        lattice[2,1] = l13
        lattice[3,1] = l23
        lattice[3,2] = l33

    end


    return lattice
end

"""
    adjust_periodic_boundary_lmp!(positions::Array{Float64})

Adjust atomic positions so that atom position are not shifted with respect to periodic boundary conditions between two snapshots

# Arguments
- 'positions::Array{Float64}': 3xNionxNconfig Array of atomic position (Nion = number of atoms, Nconfig=number of MD snapshots)
"""
function adjust_periodic_boundary_lmp!(positions)
    for t in 2:size(positions, 3)  
        # Calculate difference in between positions between two snapshot
        dX = positions[:, :, t] - positions[:, :, t - 1]
        for i in 1:size(positions, 1)
            for j in 1:size(positions, 2)
                if dX[i, j] > 0.5
                    positions[i, j, t] -= 1
                elseif dX[i, j] < -0.5
                    positions[i, j, t] += 1
                end
            end
        end
    end
end
