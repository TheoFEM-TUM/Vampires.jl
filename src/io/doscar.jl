"""
    read_doscar(file::AbstractString)

Read the `DOSCAR` VASP output file and extract the density of states (DOS) data.

# Arguments
- `file::AbstractString`: The path to the `DOSCAR` file.

# Returns
- `dos::Array{Float64, 2}`: A transposed array where each row contains the energy and DOS values.
- `meta::Dict{String, Float64}`: A dictionary containing metadata from the `DOSCAR` file, including:
    - `"TEBEG"`: The initial temperature.
    - `"Nion"`: The number of ions.
    - `"Emax"`: The maximum energy.
    - `"Emin"`: The minimum energy.
    - `"NEDOS"`: The number of DOS points.
    - `"Ef"`: The Fermi energy.
"""
function read_doscar(file)
    lines = open_and_read(file)
    lines = split_lines(lines)
    meta = Dict()
    Emax, Emin, NEDOS, Ef, _ = parse.(Float64, lines[6])[1:5]
    meta["TEBEG"] = parse(Float64, lines[3][1])
    _, meta["Nion"] = parse.(Float64, lines[1])[1:2]
    meta["Emax"] = Emax; meta["Emin"] = Emin; meta["NEDOS"] = NEDOS
    meta["Ef"] = Ef
    dos = parse_lines_as_array(lines[7:Int(NEDOS)+6])
    return transpose(dos), meta
end

"""
    read_doscar_with_pdos(file::AbstractString)

Read the `DOSCAR` VASP output file and extract both the total density of states (DOS) and the projected density of states (PDOS) data.

# Arguments
- `file::AbstractString`: The path to the `DOSCAR` file.

# Returns
- `dos::Array{Float64, 2}`: A transposed array where each row contains the energy and DOS values.
- `pdos::Vector{Array{Float64, 2}}`: A vector of transposed arrays, each representing the PDOS for a specific ion, where each row contains the energy and PDOS values for different orbitals.
- `meta::Dict{String, Float64}`: A dictionary containing metadata from the `DOSCAR` file, including:
    - `"TEBEG"`: The initial temperature.
    - `"Nion"`: The number of ions.
    - `"Emax"`: The maximum energy.
    - `"Emin"`: The minimum energy.
    - `"NEDOS"`: The number of DOS points.
    - `"Ef"`: The Fermi energy.
"""
function read_doscar_with_pdos(file)
    lines = open_and_read(file)
    lines = split_lines(lines)
    meta = Dict()
    Emax, Emin, NEDOS, Ef, _ = parse.(Float64, lines[6])[1:5]
    meta["TEBEG"] = parse(Float64, lines[3][1])
    _, meta["Nion"] = parse.(Float64, lines[1])[1:2]
    meta["Emax"] = Emax; meta["Emin"] = Emin; meta["NEDOS"] = NEDOS
    meta["Ef"] = Ef
    dos = parse_lines_as_array(lines[7:Int(NEDOS)+6])
    pdos = Matrix{Float64}[]
    for i in 1:Int(meta["Nion"])
        ibegin = i*Int(NEDOS)+7+i
        iend = (i+1)*Int(NEDOS)+6+i
        atom_pdos = map(lines[ibegin:iend]) do line
            parse.(Float64, line)
        end
        push!(pdos, hcat(atom_pdos...))
    end
    return transpose(dos), pdos, meta
end

"""
    get_base_orbs(LMAXMIX)

Returns a vector of base orbital types based on the provided maximum angular momentum quantum number.

# Arguments
- `LMAXMIX::Int`: The maximum angular momentum quantum number. Determines which orbital types are included.
  - Valid values correspond to:
    - `0` for "s" orbitals,
    - `1` for "p" orbitals,
    - `2` for "d" orbitals,
    - `3` for "f" orbitals.

# Returns
- A `Vector{String}` containing the base orbital types ("s", "p", "d", "f") that are allowed based on the `LMAXMIX` input.
"""
function get_base_orbs(LMAXMIX)
    base_orbs = String[]
    for (l, orb) in enumerate(["s", "p", "d", "f"])
        if l-1 ≤ LMAXMIX
            push!(base_orbs, orb)
        end
    end
    return base_orbs
end

"""
    get_pdos_orbital_list(; ISPIN=1, LORBIT=0, LSORBIT=false, LMAXMIX=2)

Generates a list of orbital states for projected density of states (PDOS) calculations based on specified INCAR parameters for spin, orbital decomposition, and angular momentum.

# Keywords
- `ISPIN::Int`: The spin state to consider for the orbital list.
  - `1` corresponds to non-spin-polarized orbitals (default).
  - `2` corresponds to spin-polarized orbitals.

- `LORBIT::Int`: Values greater than `10` indicate that the orbitals are m-decomposed.

- `LSORBIT::Bool`: Indicates whether spin-orbit coupling effects should be included.
  - `false` (default) means spin-orbit coupling is not considered.
  - `true` means spin-orbit coupling is considered

- `LMAXMIX::Int`: The maximum angular momentum quantum number used to determine the base orbitals.
  - Affects which base orbitals are included in the output list.

# Returns
- A `Vector{String}` containing the orbital states for PDOS calculations. The output will depend on the values of the parameters:
  - If `LORBIT` > 10, it provides decomposed orbital names for "s", "p", "d", and "f".
  - If `ISPIN` is `2`, it appends "(up)" and "(down)" to each orbital name.
  - If `LSORBIT` is `true`, it appends "(total)", "(mx)", "(my)", and "(mz)" to each orbital name.
"""
function get_pdos_orbital_list(;ISPIN=1, LORBIT=0, LSORBIT=false, LMAXMIX=2)
    base_orbs = get_base_orbs(LMAXMIX)
    orbs_out = String[]

    if LORBIT > 10  # orbitals are m-decomposed
        for orb in base_orbs
            if orb == "s"
                push!(orbs_out, "s")
            elseif orb == "p"
                append!(orbs_out, ["p_y", "p_x", "p_z"])
            elseif orb == "d"
                append!(orbs_out, ["d_xy", "d_yz", "d_z2", "d_xz", "d_x2-y2"])
            elseif orb == "f"
                ["f_z^3", "f_xz^2", "f_yz^2", "f_x(x^2-3y^2)", "f_y(3x^2-y^2)", "f_xyz", "f_x^3-3xy^2"]
            end
        end
    else
        orbs_out = base_orbs
    end

    if ISPIN == 2  # orbitals are spin polarized
        orbs_out = [string(orb, suffix) for orb in orbs_out for suffix in ["(up)", "(down)"]]
    end

    if LSORBIT == true  # spin-orbit coupling is switched on
        orbs_out = [string(orb, suffix) for orb in orbs_out for suffix in ["(total)", "(mx)", "(my)", "(mz)"]]
    end


    return orbs_out
end