"""
    read_xdatcar(xdatcar::AbstractString) -> Xdatcar

Read the configurations in the `xdatcar` file and store them in an `Xdatcar` object.

# Arguments
- `xdatcar::AbstractString`: The path to the XDATCAR file.

# Returns
- `lattice::Array{Float64, 3}`: A 3x3 array representing the lattice vectors.
- `configs::Array{Float64, 3}`: A 3D array of shape (3, Nion, Nconfig), where each 3xNion slice represents the atomic positions in a configuration.

"""
function read_xdatcar(xdatcar="XDATCAR")
    lines = open_and_read(xdatcar)
    lines = split_lines(lines)

    # Scaling parameter
    a = parse(Float64, lines[2][1])

    # Lattice vectors
    lattice = a .* parse_lines_as_array(lines[3:5], i1=1, i2=3)

    # Number of ions
    Nion = sum(parse.(Int64, lines[7]))

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

    return lattice, configs
end

"""
    read_xdatcar_npt(xdatcar::AbstractString) -> Tuple{Array{Float64, 3}, Array{Float64, 3}}

Read the configurations in the `xdatcar` file and return the lattice vectors and configurations.

# Arguments
- `xdatcar::AbstractString`: The path to the XDATCAR file.

# Returns
- `lattice::Array{Float64, 3}`: A 3x3xNconfig array where each slice `lattice[:, :, k]` represents the lattice vectors for configuration `k`.
- `configs::Array{Float64, 3}`: A 3xNionxNconfig array where each slice `configs[:, :, k]` represents the atomic positions for configuration `k`.
"""
function read_xdatcar_npt(xdatcar)
    lines_ = open_and_read(xdatcar)
    lines = split_lines(lines_)
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
    return lattice, configs
end