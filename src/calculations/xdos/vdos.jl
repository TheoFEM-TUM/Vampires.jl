function vdos(v::AbstractArray, timestep::Float64, method::String)
    # Compute frequencies in cm^-1
    c = 299792458.0 # Speed of light in m/s # TODO: use PhysicalConstants
    omega = rfftfreq(size(v, 3), timestep * 1e-15) ./ c ./ 100

    # Merge atom and coordinate index into one axis
    v = reshape(v, :, size(v, 3))

    # Compute the actual autocorrelation
    vac = nothing
    if method == "fourier"
        vac = [autocorr_fft(v[:, i]) for i in axes(v, 2)]
    elseif method == "zero_padding"
        vac = [autocorr_zero_padding(v[:, i]) for i in axes(v, 2)]
    elseif method == "shrinking_window"
        vac = [autocorr_shrinking_window(v[:, i]) for i in axes(v, 2)]
    else
        error("Method $method not implemented")
    end

    # Average over atoms and coordinates
    return omega, mean(hcat(vac...), dims=2) |> vec
end




# Placeholder functions for methods not defined in the input
function autocorr_zero_padding(v::AbstractVector)
    error("autocorr_zero_padding method not implemented")
end

function autocorr_shrinking_window(v::AbstractVector)
    error("autocorr_shrinking_window method not implemented")
end
