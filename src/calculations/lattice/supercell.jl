"""
    multiply_primitive_cell(poscar, Ns::Vector{Int64}; digits=10)

Create a supercell by multiplying the primitive cell specified in the `poscar` object by the scaling factors 
provided in the `Ns` vector. The resulting supercell will have the atomic positions and types adjusted 
accordingly.

# Arguments
- `poscar::Poscar`: The primitive cell represented as a `Poscar` object. This object should contain the 
  lattice vectors, atomic positions (in fractional coordinates), and atomic types.
- `Ns::Vector{Int64}`: A vector of three integers specifying the scaling factors along the a, b, and c 
  lattice directions, respectively.
- `digits::Int` (optional): The number of digits to round the fractional coordinates of the atoms in the 
  resulting supercell. Default is 10.

# Returns
- `Poscar`: A new `Poscar` object representing the supercell. This includes the scaled lattice vectors, 
  updated atomic positions (in fractional coordinates), and atomic types.
"""
function multiply_primitive_cell(poscar, Ns::Vector{Int64}; digits=10)
    Nion = size(poscar.rs_atom, 2)
    Nion_sc = Nion*prod(Ns)

    Rs_sc = zeros(3, Nion_sc)
    sc_ion_types = Array{String}(undef, Nion_sc)

    # Multiply lattice vectors
    sc_lattice = similar(poscar.lattice)
    for i in 1:3
        sc_lattice[:, i] = Ns[i] .* poscar.lattice[:, i]
    end

    # For each N, translate each atom by the respective translation vector
    k=1
    for n1 in 1:Ns[1], n2 in 1:Ns[2], n3 in 1:Ns[3]
        ΔR⃗ = [n1, n2, n3] .- 1
        for i in 1:Nion
            Rs_sc[:, k] = transform_basis(poscar.rs_atom[:, i] .+ ΔR⃗, inv(diagm(Ns)))
            sc_ion_types[k] = poscar.atom_types[i]
            k += 1
        end
    end

    # Permute atom positions to group atoms of same species
    # by is defined such that the order of atom species is maintained compared to the PC
    inds = sortperm(sc_ion_types, by=type->findfirst(atom_name->atom_name==type, poscar.atom_names))
    sc_ion_types = sc_ion_types[inds]
    Rs_sc = round.(Rs_sc[:, inds], digits=digits)
    unique_ion_types = unique(sc_ion_types)
    ion_numbers = [count(t->t==type, sc_ion_types) for type in unique_ion_types]
    return Poscar(1., sc_lattice, unique_ion_types, ion_numbers, Rs_sc, sc_ion_types)
end

multiply_primitive_cell(poscar, N::Int64) = multiply_primitive_cell(poscar, [N, N, N])