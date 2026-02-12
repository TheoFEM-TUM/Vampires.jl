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
    compute_velocities(x::Array{Float64, 3}, timestep<:Number, cell::Matrix{Float64}) -> Array{Float64, 3}

Compute particle velocities from their positions over time, taking into account periodic boundary conditions (PBC).
Input is assumed in units of Å (`x`) and fs (`timestep`). Output is in units of m/ps.

# Arguments
- `x::Array{Float64, 3}`: A 3D array representing particle positions in fractional coordinates. The array shape is `(d, n, t)`, where:
    - `d` is the number of spatial dimensions,
    - `n` is the number of particles,
    - `t` is the number of timesteps.
- `timestep::Float64`: The time interval between consecutive timesteps in fs.
- `cell::Matrix{Float64}`: A matrix where each column represents a lattice vector of the simulation cell. This defines the periodic boundary conditions (PBC).

# Returns
- `Array{Float64, 3}`: A 3D array of velocities with the same shape as the input array `x` in units of m/s, except along the time dimension, which is reduced by one (i.e., shape `(d, n, t-1)`). Each velocity is computed as the finite difference of positions, adjusted for boundary crossings, divided by the timestep.
"""
function compute_velocities(x::Array{Float64, 3}, timestep::T, cell::Matrix{Float64}) where T <: Number
    adjust_pos_PBC!(x)
    x_diff = diff(x, dims=3)
    dr_pbc = frac_to_cart(x_diff, cell)*u"Å"
    return ustrip.(uconvert.(u"m/ps", (dr_pbc) ./ (timestep*u"fs")))  # convert Å / fs -> m / ps and return raw values
end

"""
    rattle_cell(strc; σmin=0.03, σmax=0.10, min_dist_factor=0.8, strain_max=0.0,
                N=1, method="gaussian", attempt_max=20)

Generate physically reasonable distorted structures from a base structure for.

The function applies:
1. Optional isotropic strain to the lattice vectors.
2. Random atomic displacements scaled by atomic masses.
3. Rejection of structures where atoms are closer than a specified fraction of the 
   original minimum interatomic distance.

# Arguments
- `strc`: Structure object

# Keyword Arguments
- `sigma_min`, `sigma_max` :: Float64 - Minimum and maximum displacement amplitude (Å).
- `min_dist_factor` :: Float64 - Minimum allowed interatomic distance relative to original.
- `strain_max` :: Float64 - Maximum isotropic lattice strain (fractional, e.g., 0.01 = ±1%).
- `N` :: Int - Number of rattled structures to generate.
- `method` :: String - `"gaussian"` (default) or `"uniform"` displacement.
- `attempt_max` :: Int - Maximum rejection attempts per structure.
- `alpha` :: Float64 - Parameter for mass scaling of distortion (0 = no scaling, <1 = soft scaling, >1 = strong scaling).

# Returns
- `Structure` object containing:
    - `positions` :: 3 × N_atoms × N array of rattled positions.
    - `lattice`   :: 3 × 3 × N array of lattices.
    - Original atomic information copied from `strc`.
"""
function rattle_cell(strc; sigma_min=0.03, sigma_max=0.10, min_dist_factor=0.8, strain_max=0.0,
                           N=1, method="gaussian", attempt_max=20, alpha=0.5)

    lattice = strc.lattice
    positions = frac_to_cart(strc.positions, lattice)

    mass_dict = Dict{String, Float64}()
    for type in strc.atom_names
        mass = elements[Symbol(type)].atomic_mass
        mass_dict[type] = mass / unit(mass)
    end

    # reference minimum distance
    Natoms = size(positions, 2)
    function min_distance(pos)
        dmin = Inf
        for i in 1:Natoms-1, j in i+1:Natoms
            d = norm(pos[i] - pos[j])
            dmin = min(dmin, d)
        end
        return dmin
    end

    ref_min_dist = min_distance(positions)
    mass_min = minimum(values(mass_dict))

    rattled_positions = zeros(3, size(positions, 2), N)
    rattled_lattice = zeros(3, 3, N)
    for n in 1:N
        attempt = 0
        success = false

        while attempt < attempt_max && !success
            attempt += 1

            # optional isotropic strain
            ε = 0.0
            if strain_max > 0
                ε = rand() * 2*strain_max - strain_max
            end
            strain_matrix = (1 + ε) * I
            new_lattice = lattice * strain_matrix

            # scale positions with lattice
            new_positions = [(strain_matrix * p) for p in eachcol(positions)]

            # select displacement amplitude
            σ0 = rand()*(sigma_max - sigma_min) + sigma_min

            # apply atomic displacements
            for i in axes(positions, 2)
                mass_i = mass_dict[strc.atom_types[i]]
                σi = σ0 * (mass_min / mass_i)^alpha
                disp = method == "gaussian" ? randn(3) .* σi :
                       method == "uniform"  ? (2rand(3).-1) .* σi :
                       error("Unknown method $method, choose 'gaussian' or 'uniform'")
                new_positions[i] += disp
            end

            # reject if atoms too close
            if min_distance(new_positions) >= min_dist_factor * ref_min_dist
                rattled_positions[:, :, n] = cart_to_frac(hcat(new_positions...), new_lattice)
                rattled_lattice[:, :, n]   = new_lattice
                success = true
            end
        end
    end
    lattice_out = strain_max == 0 ? strc.lattice : rattled_lattice
    return Structure(strc.a, lattice_out, strc.atom_names, strc.atom_numbers, rattled_positions, strc.velocities, strc.atom_types)
end