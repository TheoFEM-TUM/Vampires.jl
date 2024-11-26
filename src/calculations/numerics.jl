"""
    compute_spectral_density(v::Array{Float64}, normalize::Bool) -> AbstractVector

Computes the autocorrelation of a vector using the Fast Fourier Transform (FFT).

# Arguments
- `v::Array{Float64}`: The input vector for which the autocorrelation is to be computed.
- `normalize::Bool`: if true, this returns an auto-covariance function

# Returns
- `AbstractVector`: A vector containing the spectral density values.
"""
function compute_spectral_density(v::Array{<:Number}; normalize=true)
    return abs2.(rfft(v .- mean(v) .* Int(normalize)))
end

"""
    compute_spectral_density(v::Array{Float64}, normalize::Bool) -> AbstractVector

Computes the autocorrelation of a vector using the Fast Fourier Transform (FFT) using the Wiener–Khinchin Theorem with PBC.

# Arguments
- `v::AbstractVector`: The input vector for which the autocorrelation is to be computed.
- `normalize::Bool`: if true, this returns an auto-covariance function

# Returns
- `AbstractVector`: A vector containing the autocorrelation values.
"""

function compute_autocorr(v::Array{<:Number}; normalize=true)
    return irfft(compute_spectral_density(v; normalize), size(v, 1))
end

"""
    compute_full_autocorrelation(x::Vector{T}) -> Vector{Float64}

Computes the full autocorrelation of the input vector `x`, returning a vector of length `2n - 1`, where `n` is the length of `x`.

# Arguments
- `x::Vector{T}`: A one-dimensional array of numerical values.

# Returns
- A vector of `Float64` values containing the autocorrelation values for all possible lags. The center value (at index `n`) corresponds to the zero-lag autocorrelation, and the values before and after correspond to negative and positive lags, respectively.

# Notes
- The calculation for each lag `k` (positive or negative) involves the dot product of overlapping segments of `x`, ensuring symmetric results.
- The function ensures the autocorrelation is correctly calculated for all lags, including handling edge cases at both ends of the input vector.
"""
function compute_full_autocorrelation(x)
    n = length(x)
    result = Array{Float64}(undef, 2 * n - 1)
    @inbounds for lag in 1:(n-1)
        result[n + lag] = sum(x[1:(n - lag)] .* x[(1 + lag):n])
        result[n - lag] = sum(x[(lag + 1):n] .* x[1:(n - lag)])
    end
    result[n] = sum(x .* x)
    return result
end

"""
    _get_finite_difference_coef(N)

Returns the finite difference coefficients for the second derivative, given a stencil of `N` points. These coefficients can be used to approximate the second derivative in numerical methods, where the accuracy improves with larger stencil sizes (see, e.g., https://en.wikipedia.org/wiki/Finite_difference_coefficient).

# Arguments
- `N::Int`: The number of points in the finite difference stencil. Must be an integer between 3 and 8 (inclusive).

# Returns
- `Vector{Float64}`: A vector of finite difference coefficients for the specified stencil size.
"""
function _get_finite_difference_coef(N, )
    if N < 3
        error("Finite difference method needs at least 3 points.")
    elseif N == 3
        return [1, -2, 1]
    elseif N == 4
        return [2, -5, 4, -1]
    elseif N == 5
        return [35/12, -26/3, 19/2, -14/3, 11/12]
    elseif N == 6
        return [15/4, -77/6, 107/6, -13, 61/12, -5/6]
    elseif N == 7
        return [203/45, -87/5, 117/4, -254/9, 33/2, -27/5, 137/180]
    elseif N == 8
        return [469/90, -223/10, 879/20, -949/18, 41, -201/10, 1019/180, -7/10]
    else
        error("Finite difference method for order $N is not implemented.")
    end
end

function evaluate_finite_difference(x, dt, N=3)
    coeffs = _get_finite_difference_coef(N)
    (x ⋅ Es) ./ dt
end