"""
    read_poscar(poscar::AbstractString) -> Poscar

Extract all data from the POSCAR file at `poscar`.

# Arguments
- `poscar::AbstractString`: The path to the POSCAR file.

# Returns
- `Poscar`: A `Poscar/Structure` struct containing all the extracted data from the POSCAR file, including:
    - `a`: The scaling factor.
    - `lattice`: The 3x3 array of lattice vectors.
    - `atom_names`: An array of atom names.
    - `atom_numbers`: An array of the number of each type of atom.
    - `positions`: A 3xNionx(Nconfig=1) array of atomic positions.
    - `atom_types`: An array of atom types corresponding to each atom position.
"""
function read_poscar(poscar="POSCAR")
    lines = open_and_read(poscar)
    lines = split_lines(lines)

    a, lattice, atom_names, atom_numbers, atom_types, Nion = parse_structure_file_header(lines[1:7])
    # TODO: check if Cartesian and convert
    positions = zeros(Float64, 3, Nion)
    for i in 1:Nion
       positions[:, i] = [parse(Float64, el) for el in lines[8+i][1:3]]
    end
    return Structure(a, lattice, atom_names, atom_numbers, positions, atom_types)
end

"""
    write_poscar(poscar::Structure; system_name="unknown_system", filename="POSCAR")

Write a `Poscar/Structure` struct to a POSCAR file.

# Arguments
- `poscar::Structure`: The `Poscar/Structure` struct to be written to file.
- `system_name::String`: The name of the system to be written at the top of the POSCAR file. Default is "unknown_system".

# Returns
- Nothing. The function writes the data to a file named "POSCAR" (default).
"""
function write_poscar(poscar::Structure; system_name="unknown_system", filename="POSCAR")
    file = open(filename, "w+")
    println(file, system_name)
    println(file, " 1.00")
    for i in 1:3
        sp1 = poscar.lattice[1, i] ≥ 0 ? " " : ""
        sps = [poscar.lattice[k, i] ≥ 0 ? "   " : "  " for k in 2:3]
        println(file, sp1, poscar.lattice[1, i], sps[1], poscar.lattice[2, i], sps[2], poscar.lattice[3, i])
    end
    print(file, "  ")
    for type in poscar.atom_names; print(file, type); print(file, "  "); end
    print(file, "\n")
    print(file, "  ")
    for number in poscar.atom_numbers; print(file, number); print(file, "  "); end
    print(file, "\n")
    println(file, "Direct")
    for i in axes(poscar.positions, 2)
        pos = poscar.positions[:, i]
        sp1 = pos[1] > 0 ? " " : ""
        sps = [pos[i] > 0 ? "   " : "  " for i in 2:3]
        println(file, sp1, pos[1], sps[1], pos[2], sps[2], pos[3], "   ", poscar.atom_types[i])
    end
    close(file)
end

"""
    add_atom_counts!(atom_types)

Modifies the `atom_types` array in-place by appending a unique count suffix to each atom type.
This function is useful for assigning unique labels to atoms of the same type when differentiating them
is necessary (e.g., when visualizing or processing atomic data).

# Arguments
- `atom_types`: A vector of strings where each element represents an atom type. The function appends a suffix `"-i"`
  to each atom type, where `i` is a unique integer for each occurrence of that type.
"""
function add_atom_counts(atom_types)
    counted_atom_types = map(enumerate(atom_types)) do (n, type)
        i = count(t->t==type, atom_types[1:n-1]) + 1
        type * "-$i"
    end
    return counted_atom_types
end