"""
    get_bandgap(Es::Array{Float64, 2}, kvalmax::Int64; printit::Bool=false) -> Float64

Calculate the bandgap from the given energy values.

# Arguments
- `Es::Array{Float64, 2}`: A 2D array of energy values where rows correspond to different k-points and columns correspond to different energy bands.
- `kvalmax::Int64`: The index of the highest occupied energy band (valence band maximum).
- `printit::Bool=true`: A boolean flag to control whether the bandgap value should be printed. Default is `true`.

# Returns
- `ΔE::Float64`: The calculated bandgap energy.
"""
function get_bandgap(Es, kvalmax::Int64; printit=false)
    valmax = maximum(Es[kvalmax, :])
    condmin = minimum(Es[kvalmax+1, :])
    ΔE = condmin - valmax
    if printit; @show ΔE; end
    return ΔE
end

"""
    get_bandgap(Es, occs; printit::Bool=false) -> Float64

Calculate the bandgap from the energy eigenvalues and occupation numbers.

# Arguments
- `Es::AbstractMatrix`: The energy eigenvalues.
- `occs::AbstractMatrix`: The occupation numbers.
- `printit::Bool=true`: A boolean flag to control whether the bandgap value should be printed. Default is `true`.

# Returns
- `ΔE::Float64`: The calculated bandgap energy.
"""
function get_bandgap(Es, occs; printit=false)
    VBM, CBM, _ = get_vbm_and_cbm(Es, occs)
    ΔE = CBM - VBM
    if printit; @show ΔE; end
    return ΔE
end

function get_bandgap(file::AbstractString; printit=false)
    _, Es, occs = read_eigenval(file)
    get_bandgap(Es, occs, printit=printit)
end



"""
    get_vbm_and_cbm(Es::Array{Float64, 2}, occs::Array{Float64, 2}; occ_threshold::Float64=0.9, printit::Bool=false) -> Tuple{Float64, Float64, Tuple{Int64, Int64}}

Determine the valence band maximum (VBM) and conduction band minimum (CBM) from energy values and occupations.

# Arguments
- `Es::Array{Float64, 2}`: A 2D array of energy values where rows correspond to different energy bands and columns correspond to different k-points.
- `occs::Array{Float64, 2}`: A 2D array of occupation values corresponding to the energy values in `Es`.
- `occ_threshold::Float64=0.9`: The occupation threshold to distinguish between occupied and unoccupied bands. Default is `0.9`.

# Returns
- `VBM::Float64`: The valence band maximum energy.
- `CBM::Float64`: The conduction band minimum energy.
- `VBM_Index::Tuple{Int64, Int64}`: A tuple containing the band index and k-point index of the VBM.
"""
function get_vbm_and_cbm(Es, occs; occ_threshold=0.9, printit=false)
    val_maxs = Float64[]
    cond_mins = Float64[]
    vbm_indices = Int64[]
    for (k, band_occ) in enumerate(eachcol(occs))
        occupied_bands = filter(x->x>occ_threshold, band_occ)
        vbm_index = length(occupied_bands)
        push!(vbm_indices, vbm_index)
        push!(val_maxs, Es[vbm_index, k])
        push!(cond_mins, Es[vbm_index+1, k])
    end
    _, vbm_k_index = findmax(val_maxs)
    vbm_index = vbm_indices[vbm_k_index]
    vbm = maximum(val_maxs)
    cbm = minimum(cond_mins)
    if printit; @show (vbm, cbm); end
    return vbm, cbm, (vbm_index, vbm_k_index)
end


"""
    get_fermi_level(Es, occ; occ_threshold=0.9, printit::Bool=false)

Calculate the Fermi level of a system given the energy levels and their corresponding occupancies.

# Arguments
- `Es::Array{Float64, 2}`: A 2D array of energy values where rows correspond to different energy bands and columns correspond to different k-points.
- `occs::Array{Float64, 2}`: A 2D array of occupation values corresponding to the energy values in `Es`.
- `occ_threshold::Float64=0.9`: The occupation threshold to distinguish between occupied and unoccupied bands. Default is `0.9`.

# Returns
- `E_fermi::Float64`: Fermi energy for semiconductor
"""
function get_fermi_energy(Es, occ; occ_threshold=0.9, printit=false)
    println(printit)
    vbm, cbm, _ = get_vbm_and_cbm(Es, occ; occ_threshold)
    E_fermi = cbm - abs(cbm - vbm) * 0.5
    if printit; @show E_fermi; end
    return E_fermi
end

"""
    ParabolicDispersion

A structure that represents a parabolic dispersion relation for energy eigenvalues.

# Fields
- `E0::Float64`: The energy offset (or the minimum energy) of the dispersion, typically representing the value of energy at the wave vector `k = 0` or at the band minimum.
"""
struct ParabolicDispersion
    E0 :: Float64
end
@. (f::ParabolicDispersion)(k, p) = f.E0 + (p[1]/2)*k^2

"""
    get_effective_mass(kp, Es, lattice)

Calculate the effective mass of charge carriers by fitting a parabolic dispersion relation
to the energy eigenvalues `Es` as a function of the k-point positions `kp`.

# Arguments
- `kp::Array{T, 2}`: A 2D array of k-point positions in fractional coordinates, where each column
  corresponds to a k-point in the Brillouin zone.
- `Es::Array{T, 1}`: A 1D array of energy eigenvalues (in eV) at each k-point.
- `lattice::Array{T, 2}`: The lattice basis vectors, used to convert fractional k-points to Cartesian coordinates.
- `method::String`: The method that is used to calculate the effective mass

# Returns
- `meff::Float64`: The effective mass, calculated by fitting a parabolic function to the energy
  dispersion around the band edge.
"""
function get_effective_mass(kp, Es, lattice; method="parabola")
    method = method == "none" ? "parabola" : method
    bs = get_bs(lattice)
    kp_cart = frac_to_cart(kp, bs)

    xs = [norm(kp_cart[:, 1] .- kp_cart[:, i]) for i in axes(kp_cart, 2)]

    if method[1] == 'p'
        f = ParabolicDispersion(Es[1])
        fit = curve_fit(f, xs, Es, [0.])
        d2E_dk2 = coef(fit)[1]
    elseif method[1] == 'f'
        c_i = _get_finite_difference_coef(length(Es))
        d2E_dk2 = (c_i ⋅ Es) / xs[2]^2
        d2E_dk2
    end

    meff = uconvert(u"kg", ħ^2 / (d2E_dk2*u"eV*Å^2"))

    return meff / m_e
end

function get_effective_mass(kp, Es::AbstractMatrix, lattice; method="parabola")
    meffs = zeros(length(eachcol(Es)))
    @views for (i, E_band) in enumerate(eachcol(Es))
        meffs[i] = get_effective_mass(kp[:, k_ind:k_ind+N], E_band[k_ind:k_ind+N], lattice, method=method)
    end
    return meffs
end

function get_effective_mass(kp, Es::Array{<:Number, 3}, lattice; method="parabola")
    meffs = zeros(size(Es, 1), size(Es, 3))
    @views for j in axes(meffs, 2), i in axes(meffs, 1)
        meffs[i, j] = get_effective_mass(kp[:, k_ind:k_ind+N], Es[i, k_ind:k_ind+N, j], lattice, method=method)
    end
end

function parse_effective_mass_parameters(args, kp)
    N = parse(Int64, args["N"] == "0" ? "3" : args["N"])
    kpoint = parse.(Float64, split_line(args["kpoints"], char=','))
    k_ind = find_kpoint(kpoint, kp)
    lattice = read_poscar(joinpath(args["p"], args["poscar"])).lattice
    return N, k_ind, lattice
end