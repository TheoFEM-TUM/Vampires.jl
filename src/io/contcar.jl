"""
    read_contcar(contcar::AbstractString) -> Poscar

Read data from a CONTCAR file at `contcar`.

# Arguments
- `contcar::AbstractString`: The path to the CONTCAR file.

# Returns
- `Poscar`: A `Contcar/Structure` struct containing all the extracted data from the CONTCAR file, including:
    - `a`: The scaling factor.
    - `lattice`: The 3x3 array of lattice vectors.
    - `atom_names`: An array of atom names.
    - `atom_numbers`: An array of the number of each type of atom.
    - `positions`: A 3xNionx(Nconfig=1) array of atomic positions.
    - `atom_types`: An array of atom types corresponding to each atom position.
- `init_velocities`: A 3xNionx(Nconfig=1) array of initial velocities.
"""
function read_contcar(contcar::AbstractString="CONTCAR")
    lines = open_and_read(contcar)
    lines = split_lines(lines)

    a, lattice, atom_names, atom_numbers, atom_types, Nion = parse_structure_file_header(lines[1:7])
    positions = zeros(Float64, 3, Nion)
    for i in 1:Nion
        positions[:, i] = [parse(Float64, el) for el in lines[8+i][1:3]]
    end
    if "cart" in lowercase.(lines[8])
        positions = cart_to_frac(positions, lattice)
    end
    init_velocities = zeros(Float64, 3, Nion)
    start = 10+Nion
    for i in start:(start+Nion-1)
        init_velocities[:, i-start+1] = [parse(Float64, el) for el in lines[i][1:3]]
    end
    return Structure(a, lattice, atom_names, atom_numbers, positions, atom_types), init_velocities
end