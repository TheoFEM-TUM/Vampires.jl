"""
    transform_basis(r⃗, Ê)

Transform the basis of vector `r⃗` to the basis defined by `Ê`.

# Arguments
- `r⃗::AbstractVector{T}`: The vector to be transformed.
- `Ê::AbstractMatrix{T}`: The matrix defining the new basis.

# Returns
- The transformed vector `r⃗` in the new basis defined by `Ê`.
"""
transform_basis(r⃗, Ê) = Ê * r⃗

"""
    frac_to_cart(r⃗_frac, lattice)

Convert fractional coordinates to Cartesian coordinates.

# Arguments
- `r⃗_frac::AbstractVector{T}`: The vector in fractional coordinates.
- `lattice::AbstractMatrix{T}`: The lattice vectors matrix.

# Returns
- The vector in Cartesian coordinates.
"""
frac_to_cart(r⃗_frac, lattice) = transform_basis(r⃗_frac, lattice)

"""
    cart_to_frac(r⃗_cart, lattice)

Convert Cartesian coordinates to fractional coordinates.

# Arguments
- `r⃗_cart::AbstractVector{T}`: The vector in Cartesian coordinates.
- `lattice::AbstractMatrix{T}`: The lattice vectors matrix.

# Returns
- The vector in fractional coordinates.
"""
cart_to_frac(r⃗_cart, lattice) = transform_basis(r⃗_cart, inv(lattice))

"""
    get_volume(a::AbstractMatrix{T}) where T<:Real

Calculate the volume spanned by the three vectors `a`.

# Arguments
- `a::AbstractMatrix{T}`: A 3x3 matrix where each column represents a real lattice vector.

# Returns
- The volume spanned by the three lattice vectors.
"""
get_volume(a) = a[:, 1] ⋅ (a[:, 2] × a[:, 3])

"""
    get_bs(a::AbstractMatrix{T}) where T<:Real

Calculate the reciprocal lattice vectors given the real lattice vectors `a`.

# Arguments
- `a::AbstractMatrix{T}`: A 3x3 matrix where each column represents a real lattice vector.

# Returns
- A 3x3 matrix where each column represents a reciprocal lattice vector.
"""
function get_bs(a)
    V = get_volume(a)
    b = zeros(3, 3)
    b[:, 1] = 2π / V .* (a[:, 2] × a[:, 3])
    b[:, 2] = 2π / V .* (a[:, 3] × a[:, 1])
    b[:, 3] = 2π / V .* (a[:, 1] × a[:, 2])
    return b
end
