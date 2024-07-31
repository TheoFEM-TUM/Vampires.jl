"""
    exp_2πi(R⃗::AbstractArray, k⃗::AbstractArray) -> AbstractArray

Calculate the phase factor for `R⃗` and `k⃗`.

# Arguments
- `R⃗::AbstractArray`: A vector or matrix representing the real-space coordinates.
- `k⃗::AbstractArray`: A vector representing the k-point in reciprocal space.

# Returns
- An array where each element is calculated as `exp(2πim * dot(R⃗, k⃗))`, computed element-wise.
"""
exp_2πi(R⃗, k⃗) = @. exp(2π*im * $*(R⃗', k⃗))