"""
    read_contcar(contcar::AbstractString) -> Poscar

Read data from a CONTCAR file at `contcar`.

# Arguments
- `contcar::AbstractString`: The path to the CONTCAR file.

# Returns
- `Poscar`: A `Contcar/Structure` struct containing all the extracted data from the CONTCAR file, including:
    - `a`: The scaling factor.
    - `lattice`: The 3x3 array of lattice vectors.
    - `atom_names`: An array of atom names.
    - `atom_numbers`: An array of the number of each type of atom.
    - `positions`: A 3xNionx(Nconfig=1) array of atomic positions.
    - `atom_types`: An array of atom types corresponding to each atom position.
- `init_velocities`: A 3xNionx(Nconfig=1) array of initial velocities.
"""
read_contcar(contcar::AbstractString="CONTCAR") = read_poscar(contcar)