"""
    struct Xdatcar

A structure to represent the data contained in a VASP XDATCAR file.

# Fields
- `a::Float64`: The scaling factor.
- `lattice::Array{Float64, 2}`: A 3x3 array representing the lattice vectors.
- `atom_names::Array{AbstractString, 1}`: An array of atom names.
- `atom_numbers::Array{Int64, 1}`: An array of the number of each type of atom.
- `atom_types::Array{String, 1}`: An array of atom types corresponding to each atom position.
- `configs::Array{Float64, 3}`: A 3D array of shape (3, Nion, Nconfig), where each 3xNion slice represents the atomic positions in a configuration.
"""
struct Xdatcar
    a :: Float64
    lattice :: Array{Float64, 2}
    atom_names :: Array{AbstractString, 1}
    atom_numbers :: Array{Int64, 1}
    configs :: Array{Float64, 3}
    atom_types :: Array{String, 1}
end

"""
    read_xdatcar(xdatcar::AbstractString) -> Xdatcar

Read the configurations in the `xdatcar` file and return the lattice vectors and configurations.

# Arguments
- `xdatcar::AbstractString`: The path to the XDATCAR file.

# Returns
- `Poscar`: A `Poscar` struct containing all the extracted data from the POSCAR file, including:
    - `a`: The scaling factor.
    - `lattice`: The 3x3 array of lattice vectors.
    - `atom_names`: An array of atom names.
    - `atom_numbers`: An array of the number of each type of atom.
    - `configs::Array{Float64, 3}`: 3xNionxNconfig, with Nconfig configurations represented by 3xNion coordinates
    - `atom_types`: An array of atom types corresponding to each atom position.
"""
function read_xdatcar(xdatcar="XDATCAR")
    lines = split_lines(open_and_read(xdatcar))

    a, lattice, atom_names, atom_numbers, atom_types, Nion = parse_structure_file_header(lines[1:7])

    # Find starting line of configurations
    i_start, _ = next_line_with("Direct", lines)

    # Calculate the number of configurations
    L = length(lines)
    Nconfig = Int((L - i_start + 1) / (Nion + 1))

    # Initialize the configurations array
    configs = zeros(Float64, 3, Nion, Nconfig)

    # Parse the configurations
    for j in 1:Nconfig, i in 1:Nion
        k = j + i_start + Nion * (j - 1) + i - 1
        configs[:, i, j] = parse.(Float64, lines[k][1:3])
    end

    return Xdatcar(a, lattice, atom_names, atom_numbers, configs, atom_types)
end
