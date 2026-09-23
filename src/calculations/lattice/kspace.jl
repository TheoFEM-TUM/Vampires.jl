"""
    convert_kspacing_to_kgrid(kspacing, lattice)

Convert the kspacing parameter in VASP to a k-point grid.

# Arguments
- `kspacing::Float64`: The desired k-point spacing.
- `lattice::Matrix{Float64}`: The 3x3 matrix representing the lattice vectors of the unit cell.

# Returns
- A Vector `[Nx, Ny, Nz]` representing the k-point grid in the x, y, and z directions.
"""
function convert_kspacing_to_kgrid(kspacing, lattice)
    bs = get_bs(lattice)
    return Int.(max.(1, ceil.(norm.(eachcol(bs)) ./ kspacing)))
end

"""
    find_kpoint(kpoint, kpoints)

Find the index of the first occurrence of a given k-point in an array of k-points and adjust the index
to point to the last of any consecutive duplicate k-points (as this sometimes happens for VASP bandstructures).

# Arguments
- `kpoint::AbstractVector`: The k-point to locate in `kpoints`.
- `kpoints::AbstractMatrix`: A matrix where each column represents a k-point in a multidimensional space.

# Returns
- `Int`: The index of `kpoints` where the specified `kpoint` is found, pointing to the last instance
  in any sequence of consecutive duplicates.
"""
function find_kpoint(kpoint, kpoints)
    k_ind = findfirst(k -> isapprox(k, kpoint), eachcol(kpoints))
    if k_ind ≠ nothing
        while k_ind < size(kpoints, 2) && kpoints[:, k_ind + 1] == kpoints[:, k_ind]
            k_ind += 1
        end
    end
    return k_ind
end
