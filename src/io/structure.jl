"""
    struct Structure

A structure to represent the data contained in a VASP XDATCAR or POSCAR file.
If the Structure represents an XDATCAR file, the `positions` field holds more than one configuration.

# Fields
- `a::Float64`: The scaling factor.
- `lattice::Array{Float64, 2}`: A 3x3 array representing the lattice vectors.
- `atom_names::Array{String, 1}`: An array of atom names.
- `atom_numbers::Array{Int64, 1}`: An array of the number of each type of atom.
- `atom_types::Array{String, 1}`: An array of atom types corresponding to each atom position.
- `positions::Array{Float64, 3}`: A 3D array of shape (3, Nion, Nconfig), where each 3xNion slice represents the atomic positions in a configuration;
    ! Nconfig = 1 for POSCAR files
"""
struct Structure{A, L, P}
    a :: A
    lattice :: L
    atom_names :: Array{String, 1}
    atom_numbers :: Array{Int64, 1}
    positions :: P
    atom_types :: Array{String, 1}
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