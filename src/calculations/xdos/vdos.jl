"""
    compute_vdos(v::AbstractArray{Float64}, timestep::T; method::String="full", atom_names::Array{String}=[]) where T <: Number

Compute the vibrational density of states (VDOS) from velocity data.

# Arguments
- `v::AbstractArray{Float64}`: A 3D array of shape `(n_atoms, n_dimensions, n_timesteps)` representing velocity data in units of m/ps.
- `timestep::T`: The time interval between successive velocity samples, specified in femtoseconds (fs). `T` must be a subtype of `Number`.
- `method::String="full"` (optional): The method to compute VDOS. Currently, only `"full"` is supported.
  - `"full"`: Computes the VDOS using the full velocity autocorrelation function (VACF).
  - Other methods such as `"zero_padding"` and `"shrinking_window"` are defined but not implemented.
- `atom_names::Array{String}=[]` (optional): same length as size(v, 1); An array of strings specifying the names of atoms corresponding to the velocity data. Used to assign atomic masses for normalization. If empty, masses are not considered in the computation.

# Returns
- `(ω, S)::Tuple{Vector{Float64}, Vector{Float64}}`: A tuple containing:
  - `ω`: A vector of frequencies in units of cm⁻¹.
  - `S`: The normalized spectral density of the velocity autocorrelation.
"""
function compute_vdos(v::AbstractArray{Float64}, timestep::T ; method::String="full", atom_names::Array{String}=[]) where T <: Number
    # Compute frequencies in cm^-1
    v = v*u"m/ps"  # replace unit with m/ps
    if size(atom_names)[1] > 0
        masses = Array{Quantity}(undef, size(atom_names)[1])
        @inbounds for (i, s) in enumerate(atom_names)
            masses[i] = elements[Symbol(s)].atomic_mass
        end
    else
        println("Atom species not specified. Calculating VDOS without mass weighting.")
        masses = ones(size(v, 1))
    end
    if method == "full"
        # calculate multidimensional autocorrelation -> returns 3xNionx(2*Nsteps-1)
        vac_ijn = compute_full_autocorrelation(v, masses)
        # calculate ensemble average over (x, y, z) and (atoms...)
        vac_in = reduce(vcat, sum(vac_ijn, dims=(2, 3)))  # ensemble average
        vac_norm = vac_in ./ sum(reshape(hcat([masses[j] .* v[:, j, :].^2 for j in axes(v, 2)]...), size(v)...))  # normalization
        ω = uconvert.(u"cm^-1", rfftfreq(size(vac_norm, 1), 1/(ustrip(timestep)*u"fs")) ./ c_0)
        S = compute_spectral_density(vac_norm)
        S /= maximum(S)
        return ω, S
    elseif method == "zero_padding"
        error("Method $method not implemented")
    elseif method == "shrinking_window"
        error("Method $method not implemented")
    else
        error("Method $method not implemented")
    end
end