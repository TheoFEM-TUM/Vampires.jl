"""
    read_xdatcar(xdatcar::AbstractString) -> Xdatcar

Read the configurations in the `xdatcar` file and return the lattice vectors and configurations.

# Arguments
- `xdatcar::AbstractString`: The path to the XDATCAR file.

# Returns
- `XDATCAR`: A `Xdatcar` struct containing all the extracted data from the Xdatcar file, including:
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

"""
    read_xdatcar_npt(xdatcar::AbstractString) -> Tuple{Array{Float64, 3}, Array{Float64, 3}}

Read the configurations in the `xdatcar` file and return the lattice vectors and configurations.

# Arguments
- `xdatcar::AbstractString`: The path to the XDATCAR file.

# Returns
- `XDATCAR`: A `Xdatcar` struct containing all the extracted data from the Xdatcar file, including:
    - `a`: The scaling factor.
    - `lattice`: The 3x3xNconfig array of lattice vectors for each Nconfig.
    - `atom_names`: An array of atom names.
    - `atom_numbers`: An array of the number of each type of atom.
    - `positions::Array{Float64, 3}`: 3xNionxNconfig, with Nconfig configurations represented by 3xNion coordinates
    - `atom_types`: An array of atom types corresponding to each atom position.
"""
function read_xdatcar_npt(xdatcar="XDATCAR")
    lines = split_lines(open_and_read(xdatcar))
    positions = Float64[] #Vector{Array{Float64, 2}}()
    lattices = Float64[] #Vector{Array{Float64, 2}}()
    a, lattice, atom_names, atom_numbers, atom_types, Nion = parse_structure_file_header(lines[1:7])
    for i in 1:(8+Nion):length(lines)
        a, lattice, atom_names, atom_numbers, atom_types, Nion = parse_structure_file_header(lines[i:(i+6)])
        # add lattice to the lattice vector
        push!(lattices, lattice)
        # Parse the configurations
        positions_i = zeros(Float64, 3, Nion)
        for (q, j) in enumerate((i+8):(i+7+Nion))
            positions_i[:, q] = parse.(Float64, lines[j][1:3])
        end
        # add configurations to positions
        push!(positions, positions_i)
    end
    positions = cat(positions..., dims=3)
    lattices = cat(lattices..., dims=3)
    return Structure(a, lattices, atom_names, atom_numbers, positions, atom_types)
end



"""
    write_xdatcar_body(iostream, structure::Structure, running_index=1) -> Int

Writes the atomic positions of a given `Structure` to an open `iostream` in XDATCAR format, starting with a specific running index for configurations.
Each configuration is labeled in a zero-padded format to align labels for easy reading.

# Arguments
- `iostream`: The IO stream to write to, such as a file or standard output.
- `structure::Structure`: A `Structure` object containing atomic positions to be written. The object should have a `positions` field as a 3D array with dimensions for each atom's x, y, z coordinates.
- `running_index`: The starting integer index for labeling configurations in the XDATCAR file. Defaults to 1.

# Returns
- `Int`: The updated running index after writing all configurations for this structure.

# Example
```julia
open("XDATCAR", "w") do io
    running_index = write_xdatcar_body(io, structure, 1)
end
"""
function write_xdatcar_body(iostream, structure::Structure{A, L, P}, running_index=1) where {A, L, P}
    for pos in axes(structure.positions, 3)
        num_digits = floor(Int, log10(running_index) + 1)
        println(iostream, "Direct configuration=$(repeat(" ", 6-num_digits))$(running_index)")
        for (x, y, z) in eachcol(structure.positions[:, :, pos])
            println(iostream, "    $(rpad(x, 10, '0'))    $(rpad(y, 10, '0'))    $(rpad(z, 10, '0'))")
        end
        running_index += 1
    end
    return running_index
end

"""
    write_combined_xdatcar(iostream, structure_n::Array{Structure})

Writes multiple atomic configurations from an array of `Structure` objects to an open `iostream` in XDATCAR format.
The function writes a header based on the first structure in the array and then appends each structure's atomic positions sequentially.
A running index is maintained to label each configuration for clear identification in the output.

# Arguments
- `iostream`: The IO stream to write to, such as an open file or standard output.
- `structure_n::Array{Structure}`: An array of `Structure` objects, each containing atomic positions to be written. The first structure in the array is used to generate the file header, with subsequent structures following in sequence.

# Example
```julia
# Open a file to write combined XDATCAR data from multiple structures
open("XDATCAR_combined", "w") do io
    write_combined_xdatcar(io, structure_array)
end
"""
function write_combined_xdatcar(iostream, structure_n::Array{Structure{A, L, P}}) where {A, L, P}
    running_index = 1 # to keep track of the total amount of configurations
    write_structure_file_header(iostream, structure_n[1])
    for structure in structure_n
        running_index = write_xdatcar_body(iostream, structure, running_index)
    end
    return iostream
end