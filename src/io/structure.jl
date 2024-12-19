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

"""
    write_structure_file_header(iostream, structure::Structure; system_name="unknown structure", index=1)

Writes the header information for a structure to an open `iostream` in XDATCAR format.
The header includes the system name, lattice scaling factor, lattice vectors, atomic species, and atom counts.

# Arguments
- `iostream`: The IO stream to write to, such as an open file or standard output.
- `structure::Structure`: A `Structure` object containing details about the lattice and atoms. It should have the following fields:
  - `a`: A scaling factor for the lattice vectors.
  - `lattice`: A 3x3 matrix representing the lattice vectors.
  - `atom_names`: An array of atomic species names (e.g., `["H", "O"]`).
  - `atom_numbers`: An array of integers representing the count of each atom type (e.g., `[2, 1]` for two H and one O).
- `system_name`: An optional string specifying the name of the system. Defaults to `"unknown structure"` if not provided.
- `index`: index of lattice in structure that is written in the header block (only required for NPT output)

# Example
```julia
# Open a file to write the header for a structure
open("structure_header.txt", "w") do io
    write_structure_file_header(io, structure, "Water Molecule")
end
"""
function write_structure_file_header(iostream, structure::Structure; system_name="unknown structure", index=1)
    println(iostream, system_name)
    println(iostream, "           $(structure.a)")
    for (x, y, z) in eachcol(structure.lattice[:, :, index])
        println(iostream, @sprintf "    %s%.6f   %s%.6f   %s%.6f" (sign(x) == -1 ? '-' : ' ') abs(x) (sign(y) == -1 ? '-' : ' ') abs(y) (sign(z) == -1 ? '-' : ' ') abs(z))
    end
    for element in structure.atom_names
        print(iostream, "   $element")
    end
    println(iostream, "")
    for number in structure.atom_numbers
        print(iostream, "     $number")
    end
    println(iostream, "")
end

"""
    adjust_pos_PBC!(positions::Array{Float64})

Adjust atomic positions so that atom position are not shifted with respect to periodic boundary conditions between two snapshots

# Arguments
- 'positions::Array{Float64}': 3xNionxNconfig Array of atomic position (Nion = number of atoms, Nconfig=number of MD snapshots)
"""
function adjust_pos_PBC!(positions)
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
