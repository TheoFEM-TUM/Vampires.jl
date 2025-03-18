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

function get_wannier90_eigenvalues(Hr, Rs, deg, ks)
    exp_2πiRk = exp_2πi(Rs, ks)
    Hk = zeros(ComplexF64, size(Hr, 1), size(Hr, 1), size(ks, 2))
    @views for R in axes(Rs, 2), k in axes(ks, 2)
        @. Hk[:, :, k] += Hr[:, :, R] * exp_2πiRk[R, k] / deg[R]
    end
    Es = zeros(Float64, size(Hr, 1), size(ks, 2))
    vs = zeros(ComplexF64, size(Hr, 1), size(Hr, 1), size(ks, 2))
    @views for k in axes(Hk, 3)
        eig = eigen(Hk[:, :, k])
        Es[:, k] = real.(eig.values)
        vs[:, :, k] = eig.vectors
    end
    return Es, vs
end