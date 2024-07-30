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
