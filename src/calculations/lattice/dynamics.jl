"""
    compute_msd(r⃗₀, r⃗ᵢ, lattice)

Calculates the mean-squared displacement (MSD) and its associated error over time from an initial atomic configuration (`r₀`) and a series of subsequent atomic configurations (`rᵢ`) in a molecular dynamics simulation, accounting for periodic boundary conditions.

# Arguments
- `r₀::Matrix{Float64}`: Initial atomic positions as a 3xN matrix, where `N` is the number of atoms.
- `rᵢ::Array{Float64, 3}`: Atomic positions over time as a 3xNxt matrix, where `t` is the number of time steps.
- `lattice::Matrix{Float64}`: Lattice vectors defining the periodic boundary conditions, represented as a 3x3 matrix.

# Returns
- `msd::Vector{Float64}`: The mean squared displacement over time for each time step.
- `err::Vector{Float64}`: The standard deviation of displacements for each time step, representing the error in the MSD calculation.

"""
function compute_msd(r₀, rᵢ, lattice)
    Rs = hcat([[i, j, k] for i in -1:1, j in -1:1, k in -1:1]...)
    Ts = frac_to_cart(Rs, lattice)
    err = Float64[]
    @views msd = map(axes(rᵢ, 3)) do t
        sum_square_displacements = map(axes(r₀, 2)) do i
            minimum([sum((r₀[:, i] .- rᵢ[:, i, t] .+ T).^2) for T in eachcol(Ts)])
        end
        push!(err, std(sum_square_displacements))
        mean(sum_square_displacements)
    end
    return msd, err
end

"""
    compute_velocities(x::Array{Float64, 3}, timestep::Float64, cell::Matrix{Float64}) -> Array{Float64, 3}

Compute particle velocities from their positions over time, taking into account periodic boundary conditions (PBC).

# Arguments
- `x::Array{Float64, 3}`: A 3D array representing particle positions. The array shape is `(d, n, t)`, where:
    - `d` is the number of spatial dimensions,
    - `n` is the number of particles,
    - `t` is the number of timesteps.
- `timestep::Float64`: The time interval between consecutive timesteps.
- `cell::Matrix{Float64}`: A matrix where each column represents a lattice vector of the simulation cell. This defines the periodic boundary conditions (PBC).

# Returns
- `Array{Float64, 3}`: A 3D array of velocities with the same shape as the input array `x`, except along the time dimension, which is reduced by one (i.e., shape `(d, n, t-1)`). Each velocity is computed as the finite difference of positions, adjusted for boundary crossings, divided by the timestep.
"""
function compute_velocities(x::Array{Float64, 3}, timestep::Float64, cell::Matrix{Float64})
    cellsize = norm.(eachcol(cell))

    # position differences between timesteps
    v = diff(x, dims=3)
    # take care of PBC and add one cellsize if a particle has crossed the boundary
    v .= ifelse.(v .> reshape(cellsize ./ 2, :, 1, 1), v .- reshape(cellsize, :, 1, 1),
                 ifelse.(v .< reshape(-cellsize ./ 2, :, 1, 1), v .+ reshape(cellsize, :, 1, 1), v))

    # calculate and return velocity
    return v ./ timestep
end