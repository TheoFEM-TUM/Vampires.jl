"""

"""
function compute_vdos(v::Array{Float64}, timestep::T ; method::String="full", atom_names::Array{String}=[]) where T <: Number
    # Compute frequencies in cm^-1
    c = 299792458.0  # Speed of light in m/s # TODO: use PhysicalConstants
    omega = rfftfreq(size(v, 3), timestep) ./ c ./ 100

    if size(atom_names)[1] > 0
        masses = Array{Float64}(undef, size(atom_names)[1])
        @inbounds for (i, s) in enumerate(atom_names)
            masses[i] = elements[Symbol(s)].atomic_mass.val
        end
    end
    if method == "full"
        vac = hcat([masses[j] .* compute_full_autocorrelation(v[i, j, :]) for i in axes(v, 1), j in axes(v, 2)]...)
        vac = sum(vac, dims=2)
        f = reshape(hcat([masses[j] .* v[:, j, :].^2 for j in axes(v, 2)]...), size(v)...)
        f = sum(f)
        vac ./= f
        return omega, compute_spectral_density(vac)
    elseif method == "zero_padding"
        throw("Method $method not implemented")
    elseif method == "shrinking_window"
        throw("Method $method not implemented")
    else
        throw("Method $method not implemented")
    end
end

function autocorr_zero_padding(v::AbstractVector)
    error("autocorr_zero_padding method not implemented")
end

function autocorr_shrinking_window(v::AbstractVector)
    error("autocorr_shrinking_window method not implemented")
end
