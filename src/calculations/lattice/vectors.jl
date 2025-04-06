"""
    transform_basis(r⃗, Ê)

Transform the basis of vector `r` to the basis defined by `Ê`.

# Arguments
- `r::AbstractArray{T}`: The vector to be transformed.
- `Ê::AbstractArray{U}`: The matrix defining the new basis.

# Returns
- The transformed vector `r` in the new basis defined by `Ê`.
"""
transform_basis(r::AbstractArray{T} , Ê::AbstractArray{U}) where {T<:Number, U<:Number} = Ê * r

function transform_basis(r::AbstractArray{T, 3} , Ê::AbstractArray{U, 2}) where {T<:Number, U<:Number}
    @tensor x_scaled[i, j, k] := Ê[i, m] * r[m, j, k]
end

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

"""
    get_lattice_parameter(str::Structure)

Calculate the lattice parameters (a, b, c, α, β, γ) and the unit cell volume from a `Structure`.

# Arguments
- `str::Structure`: A `Structure` object containing the lattice vectors.

# Returns
- `a`: length of the first lattice vector
- `b`: length of the first lattice vector
- `c`: length of the first lattice vector
- `α`: angle between the second and third lattice vector
- `β`: angle between the first and third lattice vector
- `γ`: angle between the first and second lattice vector
"""
function get_lattice_parameter(str::Structure)
    # calculate lengths
    a = norm(str.lattice[:, 1])
    b = norm(str.lattice[:, 2])
    c = norm(str.lattice[:, 3])
    # calculate angles in degrees
    α = acosd(dot(str.lattice[:, 2], str.lattice[:, 3]) / (b * c))
    β = acosd(dot(str.lattice[:, 1], str.lattice[:, 3]) / (a * c))
    γ = acosd(dot(str.lattice[:, 1], str.lattice[:, 2]) / (a * b))
    # Volume
    volume = get_volume(str.lattice)
    return a, b, c, α, β, γ, volume
end