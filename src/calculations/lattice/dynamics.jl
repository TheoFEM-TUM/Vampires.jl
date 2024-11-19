"""
    get_msd(r⃗₀, r⃗ᵢ, lattice)

Calculates the mean-squared displacement (MSD) and its associated error over time from an initial atomic configuration (`r₀`) and a series of subsequent atomic configurations (`rᵢ`) in a molecular dynamics simulation, accounting for periodic boundary conditions.

# Arguments
- `r₀::Matrix{Float64}`: Initial atomic positions as a 3xN matrix, where `N` is the number of atoms.
- `rᵢ::Array{Float64, 3}`: Atomic positions over time as a 3xNxt matrix, where `t` is the number of time steps.
- `lattice::Matrix{Float64}`: Lattice vectors defining the periodic boundary conditions, represented as a 3x3 matrix.

# Returns
- `msd::Vector{Float64}`: The mean squared displacement over time for each time step.
- `err::Vector{Float64}`: The standard deviation of displacements for each time step, representing the error in the MSD calculation.

"""
function get_msd(r₀, rᵢ, lattice)
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


function compute_velocities(x::Array{Float64}, timestep::Float64, cell::Matrix{Float64})
    cellsize = norm.(eachcol(cell))
    # Compute differences between timesteps
    v = diff(x, dims=3)

    println(size(cellsize))
    # Take care of periodic boundary conditions
    v = sign.(v) .* abs(v) + cellsize * Int(1 > (abs.(v) / cellsize))

    println(size(v))

    # Divide by the timestep to get the actual velocity
    return v / timestep
end