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
    - `positions::Array{Float64, 3}`: 3xNionxNconfig, with Nconfig configurations represented by 3xNion coordinates
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
    positions = zeros(Float64, 3, Nion, Nconfig)

    # Parse the configurations
    for j in 1:Nconfig, i in 1:Nion
        k = j + i_start + Nion * (j - 1) + i - 1
        positions[:, i, j] = parse.(Float64, lines[k][1:3])
    end

    return Structure(a, lattice, atom_names, atom_numbers, positions, atom_types)
end


# TODO: + should return Xdatcar structure; + tests; + should use parse_structure_file_header from poscar.jl
"""
    read_xdatcar_npt(xdatcar::AbstractString) -> Tuple{Array{Float64, 3}, Array{Float64, 3}}

Read the configurations in the `xdatcar` file and return the lattice vectors and configurations.

# Arguments
- `xdatcar::AbstractString`: The path to the XDATCAR file.

# Returns
- `lattice::Array{Float64, 3}`: A 3x3xNconfig array where each slice `lattice[:, :, k]` represents the lattice vectors for configuration `k`.
- `configs::Array{Float64, 3}`: A 3xNionxNconfig array where each slice `configs[:, :, k]` represents the atomic positions for configuration `k`.
"""
function read_xdatcar_npt(xdatcar="XDATCAR")
    lines = split_lines(open_and_read(xdatcar))
    Nconfig, config_inds = count_lines_with("Direct", lines)
    Nion = sum(parse.(Int64, lines[7]))

    lattice = zeros(3, 3, Nconfig)
    configs = zeros(3, Nion, Nconfig)

    @inbounds for (k, ind) in enumerate(config_inds)
       a = parse(Float64, lines[ind-6][1])
       lattice[:, :, k] = a .* parse_lines_as_array(lines[ind-5:ind-3], i1=1, i2=3)
       for i in axes(configs, 2)
           config = @view configs[:, i, k]
           config .= parse.(Float64, lines[ind+i])
       end
    end
    return lattice, configs # TODO: return XDATCAR
end