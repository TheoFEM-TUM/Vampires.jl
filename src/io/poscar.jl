"""
    struct Poscar

A structure to represent the data contained in a VASP POSCAR file.

# Fields
- `a::Float64`: The scaling factor.
- `lattice::Array{Float64, 2}`: A 3x3 array representing the lattice vectors.
- `atom_names::Array{AbstractString, 1}`: An array of atom names.
- `atom_numbers::Array{Int64, 1}`: An array of the number of each type of atom.
- `rs_atom::Array{Float64, 2}`: A 3xNion array of atomic positions.
- `atom_types::Array{String, 1}`: An array of atom types corresponding to each atom position.
"""
struct Poscar
    a :: Float64
    lattice :: Array{Float64, 2}
    atom_names :: Array{AbstractString, 1}
    atom_numbers :: Array{Int64, 1}
    rs_atom :: Array{Float64, 2}
    atom_types :: Array{String, 1}
end

"""
    read_poscar(poscar::AbstractString) -> Poscar

Extract all data from the POSCAR file at `poscar`.

# Arguments
- `poscar::AbstractString`: The path to the POSCAR file.

# Returns
- `Poscar`: A `Poscar` struct containing all the extracted data from the POSCAR file, including:
    - `a`: The scaling factor.
    - `lattice`: The 3x3 array of lattice vectors.
    - `atom_names`: An array of atom names.
    - `atom_numbers`: An array of the number of each type of atom.
    - `Rs`: A 3xNion array of atomic positions.
    - `atom_types`: An array of atom types corresponding to each atom position.
"""
function read_poscar(poscar)
    lines = open_and_read(poscar)
    lines = split_lines(lines)

    a, lattice, atom_names, atom_numbers, atom_types, Nion = parse_structure_file_header(lines[1:7])
    rs_atom = zeros(Float64, 3, Nion)
    for i in 1:Nion
       rs_atom[:, i] = [parse(Float64, el) for el in lines[8+i][1:3]]
    end
    return Poscar(a, lattice, atom_names, atom_numbers, rs_atom, atom_types)
end

"""
    parse_structure_file_header(lines::Vector{String}) -> Tuple

Parse the header information from the POSCAR or XDATCAR file lines.

This function extracts data from the header of a POSCAR or XDATCAR file, which contains details about the scaling factor, lattice vectors, atom names, and atom counts.
This separate function is designed to handle both POSCAR and XDATCAR formats, which have compatible header structures, making it reusable for these similar file types.

# Arguments
- `lines::Vector{String}`: The lines of the POSCAR or XDATCAR file, typically loaded as an array of strings where each element is a line from the file.

# Returns
- `Tuple`: A tuple containing:
    - `a::Float64`: The scaling factor for lattice vectors.
    - `lattice::Array{Float64, 2}`: A 3x3 array of lattice vectors, scaled by `a`.
    - `atom_names::Vector{String}`: An array of atom names (symbols) from the file.
    - `atom_numbers::Vector{Int64}`: An array of integers representing the number of atoms for each atom type.
    - `atom_types::Vector{String}`: An expanded list of atom types where each type is repeated according to the count in `atom_numbers`.
    - `Nion::Int64`: The total number of ions (atoms) in the system, computed as the sum of `atom_numbers`.

# Raises
- `Error`: If the lengths of `atom_names` and `atom_numbers` do not match, which could indicate a formatting issue in the POSCAR/XDATCAR file.

"""
function parse_structure_file_header(lines)
        # Scaling parameter
        a = parse(Float64, lines[2][1])

        # Lattice vectors
        lattice = zeros(Float64, 3, 3)
        for i in 1:3
            lattice[:, i] = @. a * parse(Float64, lines[2+i])
        end

        # Atom names and numbers
        if length(lines[6]) ≠ length(lines[7])
            throw("Length of atom_names and atom_numbers not equal, check your POSCAR!")
        end
        atom_names = lines[6]
        atom_numbers = parse.(Int64, lines[7])

        atom_types = String[]
        for (k, atom_number) in enumerate(atom_numbers), _ in 1:atom_number
            push!(atom_types, atom_names[k])
        end

        # Atom positions and types
        Nion = sum(atom_numbers)
        return (a, lattice, atom_names, atom_numbers, atom_types, Nion)
end

"""
    write_poscar(poscar::Poscar; system_name="unknown_system", filename="POSCAR")

Write a `Poscar` struct to a POSCAR file.

# Arguments
- `poscar::Poscar`: The `Poscar` struct to be written to file.
- `system_name::String`: The name of the system to be written at the top of the POSCAR file. Default is "unknown_system".

# Returns
- Nothing. The function writes the data to a file named "POSCAR" (default).
"""
function write_poscar(poscar::Poscar; system_name="unknown_system", filename="POSCAR")
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
    for i in axes(poscar.rs_atom, 2)
        pos = poscar.rs_atom[:, i]
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